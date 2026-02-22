import '../datasources/remote/firestore_source.dart';
import '../models/referral_model.dart';

class ReferralRepository {
  final FirestoreSource _firestoreSource;

  ReferralRepository(this._firestoreSource);

  static const _collection = 'referrals';

  /// Get all referrals where the user is the referrer
  Future<List<ReferralModel>> getReferralsByReferrer(String uid) async {
    final snapshot = await _firestoreSource.queryCollection(
      _collection,
      (ref) => ref.where('referrerUid', isEqualTo: uid),
    );
    return snapshot.docs
        .map((doc) => ReferralModel.fromFirestore(doc))
        .toList();
  }

  /// Get referrals where the user is the referee
  Future<List<ReferralModel>> getReferralsByReferee(String uid) async {
    final snapshot = await _firestoreSource.queryCollection(
      _collection,
      (ref) => ref.where('refereeUid', isEqualTo: uid),
    );
    return snapshot.docs
        .map((doc) => ReferralModel.fromFirestore(doc))
        .toList();
  }

  /// Get total earned rewards for a referrer
  Future<double> getTotalRewards(String uid) async {
    final referrals = await getReferralsByReferrer(uid);
    return referrals
        .where((r) => r.isRewarded)
        .fold<double>(0.0, (sum, r) => sum + r.rewardAmount);
  }
}
