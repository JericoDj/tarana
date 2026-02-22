import 'package:flutter/foundation.dart';
import '../../data/models/promo_code_model.dart';
import '../../data/models/referral_model.dart';
import '../../data/repositories/promo_repository.dart';
import '../../data/repositories/referral_repository.dart';
import '../../data/datasources/remote/cloud_functions_source.dart';

class PromoProvider extends ChangeNotifier {
  final PromoRepository _promoRepository;
  final ReferralRepository _referralRepository;
  final CloudFunctionsSource _cloudFunctions;

  PromoProvider(
    this._promoRepository,
    this._referralRepository,
    this._cloudFunctions,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Promo state
  PromoCodeModel? _appliedPromo;
  PromoCodeModel? get appliedPromo => _appliedPromo;

  double _discountAmount = 0.0;
  double get discountAmount => _discountAmount;

  List<PromoCodeModel> _activePromos = [];
  List<PromoCodeModel> get activePromos => _activePromos;

  // Referral state
  List<ReferralModel> _myReferrals = [];
  List<ReferralModel> get myReferrals => _myReferrals;

  double _totalRewards = 0.0;
  double get totalRewards => _totalRewards;

  /// Validate and apply a promo code via Cloud Functions
  Future<bool> redeemPromoCode(String code, double fare) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _cloudFunctions.call('booking-redeemPromo', {
        'code': code.toUpperCase(),
        'fare': fare,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        _appliedPromo = await _promoRepository.getPromoByCode(code);
        _discountAmount = (data['discount'] as num).toDouble();
        _successMessage =
            'Promo applied! You save ₱${_discountAmount.toStringAsFixed(0)}';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Invalid promo code.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Fallback: validate locally if Cloud Function fails
      return _validateLocally(code, fare);
    }
  }

  /// Local fallback validation
  Future<bool> _validateLocally(String code, double fare) async {
    try {
      final promo = await _promoRepository.getPromoByCode(code);
      if (promo == null) {
        _error = 'Promo code not found.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!promo.isValid) {
        _error = promo.isExpired
            ? 'This promo code has expired.'
            : promo.isUsedUp
            ? 'This promo code has reached its usage limit.'
            : 'This promo code is no longer active.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final discount = _promoRepository.calculateDiscount(promo, fare);
      if (discount <= 0) {
        _error =
            'Minimum fare of ₱${promo.minFare?.toStringAsFixed(0)} required.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _appliedPromo = promo;
      _discountAmount = discount;
      _successMessage =
          'Promo applied! You save ₱${discount.toStringAsFixed(0)}';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to validate promo code.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear applied promo
  void clearPromo() {
    _appliedPromo = null;
    _discountAmount = 0.0;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Load active promos
  Future<void> loadActivePromos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _activePromos = await _promoRepository.getActivePromos();
    } catch (e) {
      _error = 'Failed to load promos.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load referral data for a user
  Future<void> loadReferralData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myReferrals = await _referralRepository.getReferralsByReferrer(uid);
      _totalRewards = await _referralRepository.getTotalRewards(uid);
    } catch (e) {
      _error = 'Failed to load referral data.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
