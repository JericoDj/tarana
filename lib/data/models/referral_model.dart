import 'package:cloud_firestore/cloud_firestore.dart';

/// Referral model for rider/driver referral campaigns
class ReferralModel {
  final String id;
  final String referrerUid;
  final String referrerRole;
  final String refereeUid;
  final String refereeRole;
  final String status; // 'pending', 'trip_completed', 'rewarded'
  final double rewardAmount;
  final String? completedTripId;
  final DateTime createdAt;
  final DateTime? rewardedAt;

  const ReferralModel({
    required this.id,
    required this.referrerUid,
    required this.referrerRole,
    required this.refereeUid,
    required this.refereeRole,
    this.status = 'pending',
    required this.rewardAmount,
    this.completedTripId,
    required this.createdAt,
    this.rewardedAt,
  });

  bool get isRewarded => status == 'rewarded';

  factory ReferralModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralModel(
      id: doc.id,
      referrerUid: data['referrerUid'] ?? '',
      referrerRole: data['referrerRole'] ?? 'rider',
      refereeUid: data['refereeUid'] ?? '',
      refereeRole: data['refereeRole'] ?? 'rider',
      status: data['status'] ?? 'pending',
      rewardAmount: (data['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      completedTripId: data['completedTripId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rewardedAt: (data['rewardedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'referrerUid': referrerUid,
      'referrerRole': referrerRole,
      'refereeUid': refereeUid,
      'refereeRole': refereeRole,
      'status': status,
      'rewardAmount': rewardAmount,
      'completedTripId': completedTripId,
      'createdAt': Timestamp.fromDate(createdAt),
      'rewardedAt': rewardedAt != null ? Timestamp.fromDate(rewardedAt!) : null,
    };
  }
}
