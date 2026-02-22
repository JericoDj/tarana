const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

/**
 * redeemPromo — validate and redeem a promo code
 * Client sends: { code: string, fare: number }
 * Returns: { success: bool, discount: number, message: string }
 */
exports.redeemPromo = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Must be logged in.");
    }

    const { code, fare } = request.data;
    if (!code || typeof fare !== "number") {
        throw new HttpsError("invalid-argument", "Code and fare are required.");
    }

    const db = getFirestore();
    const uid = request.auth.uid;
    const upperCode = code.toUpperCase();

    const promoRef = db.collection("promo_codes").doc(upperCode);
    const promoDoc = await promoRef.get();

    if (!promoDoc.exists) {
        return { success: false, discount: 0, message: "Promo code not found." };
    }

    const promo = promoDoc.data();

    // Check active status
    if (!promo.isActive) {
        return { success: false, discount: 0, message: "This promo is no longer active." };
    }

    // Check expiry
    const now = new Date();
    if (promo.validUntil && promo.validUntil.toDate() < now) {
        return { success: false, discount: 0, message: "This promo has expired." };
    }
    if (promo.validFrom && promo.validFrom.toDate() > now) {
        return { success: false, discount: 0, message: "This promo is not yet active." };
    }

    // Check global usage limit
    if (promo.usedCount >= promo.usageLimit) {
        return { success: false, discount: 0, message: "This promo has reached its limit." };
    }

    // Check per-user usage limit
    const userUsageSnap = await db
        .collection("promo_usage")
        .where("uid", "==", uid)
        .where("code", "==", upperCode)
        .get();

    if (userUsageSnap.size >= (promo.perUserLimit || 1)) {
        return { success: false, discount: 0, message: "You have already used this promo." };
    }

    // Check minimum fare
    if (promo.minFare && fare < promo.minFare) {
        return {
            success: false,
            discount: 0,
            message: `Minimum fare of ₱${promo.minFare} required.`,
        };
    }

    // Check first ride only
    if (promo.firstRideOnly) {
        const bookingsSnap = await db
            .collection("bookings")
            .where("riderId", "==", uid)
            .where("status", "==", "completed")
            .limit(1)
            .get();
        if (!bookingsSnap.empty) {
            return { success: false, discount: 0, message: "This promo is for first ride only." };
        }
    }

    // Calculate discount
    let discount = 0;
    if (promo.type === "percentage") {
        discount = fare * (promo.value / 100);
        if (promo.maxDiscount && discount > promo.maxDiscount) {
            discount = promo.maxDiscount;
        }
    } else {
        discount = promo.value;
    }
    discount = Math.min(discount, fare);
    discount = Math.round(discount * 100) / 100;

    // Record usage
    await db.collection("promo_usage").add({
        uid: uid,
        code: upperCode,
        discount: discount,
        usedAt: FieldValue.serverTimestamp(),
    });

    // Increment usedCount
    await promoRef.update({ usedCount: FieldValue.increment(1) });

    return {
        success: true,
        discount: discount,
        message: `Promo applied! You save ₱${discount}.`,
    };
});
