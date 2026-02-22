import '../datasources/remote/firestore_source.dart';
import '../models/promo_code_model.dart';

class PromoRepository {
  final FirestoreSource _firestoreSource;

  PromoRepository(this._firestoreSource);

  static const _collection = 'promo_codes';

  /// Fetch a promo code by its code string
  Future<PromoCodeModel?> getPromoByCode(String code) async {
    try {
      final doc = await _firestoreSource.getDocument(
        _collection,
        code.toUpperCase(),
      );
      if (!doc.exists) return null;
      return PromoCodeModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Get all active promos (for admin display)
  Future<List<PromoCodeModel>> getActivePromos() async {
    final snapshot = await _firestoreSource.queryCollection(
      _collection,
      (ref) => ref.where('isActive', isEqualTo: true),
    );
    return snapshot.docs
        .map((doc) => PromoCodeModel.fromFirestore(doc))
        .toList();
  }

  /// Calculate discount amount for a given promo and fare
  double calculateDiscount(PromoCodeModel promo, double fare) {
    if (!promo.isValid) return 0.0;
    if (promo.minFare != null && fare < promo.minFare!) return 0.0;

    double discount;
    if (promo.type == 'percentage') {
      discount = fare * (promo.value / 100);
      if (promo.maxDiscount != null && discount > promo.maxDiscount!) {
        discount = promo.maxDiscount!;
      }
    } else {
      discount = promo.value;
    }

    // Discount cannot exceed the fare
    return discount > fare ? fare : discount;
  }
}
