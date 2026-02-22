import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_paths.dart';
import '../models/booking_model.dart';
import '../../shared/enums/booking_status.dart';
import '../datasources/remote/cloud_functions_source.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;
  final CloudFunctionsSource _cloudFunctions;

  BookingRepository({
    FirebaseFirestore? firestore,
    CloudFunctionsSource? cloudFunctions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudFunctions = cloudFunctions ?? CloudFunctionsSource();

  // Create a new booking via Cloud Functions
  Future<String> createBooking(BookingModel booking) async {
    try {
      return await _cloudFunctions.createBooking(
        pickup: booking.pickup.toMap(),
        dropoff: booking.dropoff.toMap(),
        paymentMethod: booking.paymentMethod.name,
      );
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Driver accepts booking via Cloud Functions
  Future<void> acceptBooking(String bookingId) async {
    try {
      await _cloudFunctions.acceptBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }

  // Driver rejects booking via Cloud Functions
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _cloudFunctions.rejectBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to reject booking: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      final updateData = {
        'status': status.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      switch (status) {
        case BookingStatus.completed:
          updateData['completedAt'] = FieldValue.serverTimestamp();
          break;
        case BookingStatus.arrived:
          updateData['arrivedAt'] = FieldValue.serverTimestamp();
          break;
        case BookingStatus.inProgress:
          updateData['startedAt'] = FieldValue.serverTimestamp();
          break;
        case BookingStatus.driverAssigned:
          updateData['acceptedAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await _firestore
          .collection(FirestorePaths.bookings)
          .doc(bookingId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(
    String bookingId,
    String reason,
    String cancelledByUid,
  ) async {
    try {
      await _firestore
          .collection(FirestorePaths.bookings)
          .doc(bookingId)
          .update({
            'status': BookingStatus.cancelled.toFirestore(),
            'cancelledBy': cancelledByUid,
            'cancellationReason': reason,
            'cancelledAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Stream a single booking
  Stream<BookingModel?> watchBooking(String bookingId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .doc(bookingId)
        .snapshots()
        .map((doc) => doc.exists ? BookingModel.fromFirestore(doc) : null);
  }

  // Stream active rider bookings
  Stream<List<BookingModel>> watchActiveRiderBookings(String riderId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .where('riderId', isEqualTo: riderId)
        .where(
          'status',
          whereIn: [
            BookingStatus.pending.toFirestore(),
            BookingStatus.searching.toFirestore(),
            BookingStatus.driverAssigned.toFirestore(),
            BookingStatus.driverArriving.toFirestore(),
            BookingStatus.arrived.toFirestore(),
            BookingStatus.inProgress.toFirestore(),
          ],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream active driver bookings
  Stream<List<BookingModel>> watchActiveDriverBookings(String driverId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .where('driverId', isEqualTo: driverId)
        .where(
          'status',
          whereIn: [
            BookingStatus.driverAssigned.toFirestore(),
            BookingStatus.driverArriving.toFirestore(),
            BookingStatus.arrived.toFirestore(),
            BookingStatus.inProgress.toFirestore(),
          ],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream incoming driver requests (status searching, driver in notifiedDrivers)
  Stream<List<BookingModel>> watchIncomingRequests(String driverId) {
    return _firestore
        .collection(FirestorePaths.bookings)
        .where('notifiedDrivers', arrayContains: driverId)
        .where('status', isEqualTo: BookingStatus.searching.toFirestore())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Record cash payment (driver confirms cash collected)
  Future<void> recordCashPayment(String bookingId) async {
    try {
      await _firestore
          .collection(FirestorePaths.bookings)
          .doc(bookingId)
          .update({
            'paymentStatus': 'completed',
            'paymentRecordedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to record cash payment: $e');
    }
  }
}
