const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * createBooking - Rider creates a booking.
 */
exports.createBooking = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "User must be logged in.");
  }

  const {pickup, dropoff, paymentMethod} = request.data;
  const riderId = auth.uid;

  if (!pickup || !dropoff || !paymentMethod) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  try {
    // 1. Check for active bookings
    const activeBookings = await db.collection("bookings")
        .where("riderId", "==", riderId)
        .where("status", "in", ["pending", "searching", "driver_assigned", "driver_arriving", "in_progress"])
        .get();

    if (!activeBookings.empty) {
      throw new HttpsError("failed-precondition", "Rider already has an active booking.");
    }

    // 2. Dummy Server-Side Fare Calculation (In production, use Google Maps API)
    // For MVP, we'll trust the client or do a simple calculation if needed.
    // Assuming client passed `fare` if we want to rely on the client estimation,
    // otherwise we build a dummy fare object here.
    const fare = request.data.fare || {
      baseFare: 50,
      distanceFare: 0,
      timeFare: 0,
      surgeMultiplier: 1.0,
      discount: 0,
      total: 50,
      currency: "PHP",
    };

    const newBooking = {
      riderId,
      status: "pending",
      pickup,
      dropoff,
      paymentMethod,
      fare,
      distanceKm: request.data.distanceKm || 0,
      durationMinutes: request.data.durationMinutes || 0,
      routePolyline: request.data.routePolyline || "",
      requestedAt: admin.firestore.FieldValue.serverTimestamp(),
      isScheduled: false,
    };

    const docRef = await db.collection("bookings").add(newBooking);
    return {bookingId: docRef.id};
  } catch (error) {
    logger.error("Error creating booking:", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", "An error occurred while creating the booking.");
  }
});

/**
 * onBookingCreated - Triggered when a booking is created.
 */
exports.onBookingCreated = onDocumentCreated("bookings/{bookingId}", async (event) => {
  const snap = event.data;
  if (!snap) return;

  const bookingId = event.params.bookingId;
  const booking = snap.data();

  // If status is not pending, do nothing
  if (booking.status !== "pending") return;

  logger.info(`Starting dispatch for booking ${bookingId}`);

  try {
    // 1. Update status to searching
    await db.collection("bookings").doc(bookingId).update({
      status: "searching",
    });

    // 2. Query RTDB for online drivers
    // In a real app with millions of drivers, use GeoFire.
    // For our MVP, we fetch all online drivers and find the closest via Haversine.
    // Or we use GeoFire directly. For simplicity, we assume RTDB has limited subset.

    // In our architecture, drivers write to `/drivers/{uid}`.
    const driversSnapshot = await admin.database().ref("drivers")
        .orderByChild("status")
        .equalTo("online")
        .once("value");

    const drivers = driversSnapshot.val();
    if (!drivers) {
      // No online drivers
      await handleNoDriversFound(bookingId, booking.riderId);
      return;
    }

    // 3. Find closest driver (simulate for MVP - just pick the first one)
    const driverUids = Object.keys(drivers);
    const selectedDriverUid = driverUids[0]; // Simplification for now

    // 4. Update booking with notified driver
    await db.collection("bookings").doc(bookingId).update({
      notifiedDrivers: [selectedDriverUid],
    });

    // 5. Send FCM to Driver
    const driverDoc = await db.collection("users").doc(selectedDriverUid).get();
    const fcmToken = driverDoc.data().fcmToken;

    if (fcmToken) {
      await messaging.send({
        token: fcmToken,
        notification: {
          title: "New Ride Request",
          body: "A passenger is looking for a ride near you.",
        },
        data: {
          bookingId: bookingId,
          type: "new_booking",
        },
      });
      logger.info(`Notified driver ${selectedDriverUid}`);
    } else {
      logger.warn(`Driver ${selectedDriverUid} has no FCM token.`);
    }
  } catch (error) {
    logger.error("Error in onBookingCreated dispatch:", error);
  }
});

/**
 * acceptBooking - Driver accepts a ride.
 */
exports.acceptBooking = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Must be logged in.");

  const {bookingId} = request.data;
  const driverId = auth.uid;

  if (!bookingId) throw new HttpsError("invalid-argument", "Missing bookingId.");

  const bookingRef = db.collection("bookings").doc(bookingId);

  try {
    await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      if (!bookingDoc.exists) {
        throw new HttpsError("not-found", "Booking not found.");
      }

      const booking = bookingDoc.data();
      if (booking.status !== "searching") {
        throw new HttpsError("failed-precondition", "Ride already taken or cancelled.");
      }

      // Update Booking
      transaction.update(bookingRef, {
        status: "driver_assigned",
        driverId: driverId,
        acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // Update Driver RTDB Status outside of Firestore transaction
    await admin.database().ref(`drivers/${driverId}`).update({
      status: "on_trip",
    });

    // Notify Rider via FCM
    const bookingDoc = await bookingRef.get();
    const riderId = bookingDoc.data().riderId;
    const riderDoc = await db.collection("users").doc(riderId).get();
    const riderToken = riderDoc.data().fcmToken;

    if (riderToken) {
      await messaging.send({
        token: riderToken,
        notification: {
          title: "Driver Assigned",
          body: "Your driver is on the way.",
        },
        data: {bookingId, type: "driver_assigned"},
      });
    }

    return {success: true};
  } catch (error) {
    logger.error("Error in acceptBooking:", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", error.message);
  }
});

/**
 * rejectBooking - Driver rejects a ride (or it times out).
 */
exports.rejectBooking = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "Must be logged in.");

  const {bookingId} = request.data;
  const driverId = auth.uid;

  if (!bookingId) throw new HttpsError("invalid-argument", "Missing bookingId.");

  const bookingRef = db.collection("bookings").doc(bookingId);

  try {
    let nextDriverUid = null;

    await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      if (!bookingDoc.exists) {
        throw new HttpsError("not-found", "Booking not found.");
      }

      const booking = bookingDoc.data();
      if (booking.status !== "searching") {
        throw new HttpsError("failed-precondition", "Ride no longer searching.");
      }

      const notifiedDrivers = booking.notifiedDrivers || [];
      if (!notifiedDrivers.includes(driverId)) {
        notifiedDrivers.push(driverId);
      }

      // Re-query RTDB for the next online driver NOT in notifiedDrivers
      const driversSnapshot = await admin.database().ref("drivers")
          .orderByChild("status")
          .equalTo("online")
          .once("value");

      const drivers = driversSnapshot.val();
      if (drivers) {
        const availableUids = Object.keys(drivers).filter((uid) => !notifiedDrivers.includes(uid));
        if (availableUids.length > 0) {
          nextDriverUid = availableUids[0];
          notifiedDrivers.push(nextDriverUid);
        }
      }

      // Update Booking
      transaction.update(bookingRef, {
        notifiedDrivers: notifiedDrivers,
      });
    });

    if (nextDriverUid) {
      // Send FCM to the next driver
      const driverDoc = await db.collection("users").doc(nextDriverUid).get();
      const fcmToken = driverDoc.data().fcmToken;

      if (fcmToken) {
        await messaging.send({
          token: fcmToken,
          notification: {
            title: "New Ride Request",
            body: "A passenger is looking for a ride near you.",
          },
          data: {bookingId, type: "new_booking"},
        });
        logger.info(`Notified NEXT driver ${nextDriverUid}`);
      }
    } else {
      // No more drivers
      const bookingDoc = await bookingRef.get();
      await handleNoDriversFound(bookingId, bookingDoc.data().riderId);
    }

    return {success: true};
  } catch (error) {
    logger.error("Error in rejectBooking:", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", error.message);
  }
});

/**
 * Helper when no drivers are found.
 * @param {string} bookingId The booking document ID.
 * @param {string} riderId The rider UID.
 */
async function handleNoDriversFound(bookingId, riderId) {
  logger.info(`No drivers found for booking ${bookingId}`);
  await db.collection("bookings").doc(bookingId).update({
    status: "cancelled",
    cancellationReason: "No drivers available",
    cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const riderDoc = await db.collection("users").doc(riderId).get();
  const riderToken = riderDoc.data().fcmToken;
  if (riderToken) {
    await messaging.send({
      token: riderToken,
      notification: {
        title: "No Drivers Available",
        body: "We couldn't find a driver near you right now. Please try again later.",
      },
      data: {bookingId, type: "booking_cancelled"},
    });
  }
}
