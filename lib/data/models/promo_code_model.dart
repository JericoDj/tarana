import 'package:cloud_firestore/cloud_firestore.dart';

/// Promo code data model
class PromoCodeModel {
  final String code;
  final String type; // 'flat' or 'percentage'
  final double value;
  final double? maxDiscount;
  final double? minFare;
  final int usageLimit;
  final int usedCount;
  final int perUserLimit;
  final bool firstRideOnly;
  final List<String> regions;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String createdBy;

  const PromoCodeModel({
    required this.code,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.minFare,
    required this.usageLimit,
    this.usedCount = 0,
    this.perUserLimit = 1,
    this.firstRideOnly = false,
    this.regions = const [],
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    required this.createdBy,
  });

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isUsedUp => usedCount >= usageLimit;
  bool get isValid => isActive && !isExpired && !isUsedUp;

  factory PromoCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromoCodeModel(
      code: doc.id,
      type: data['type'] ?? 'flat',
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (data['maxDiscount'] as num?)?.toDouble(),
      minFare: (data['minFare'] as num?)?.toDouble(),
      usageLimit: data['usageLimit'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      perUserLimit: data['perUserLimit'] ?? 1,
      firstRideOnly: data['firstRideOnly'] ?? false,
      regions: List<String>.from(data['regions'] ?? []),
      validFrom: (data['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validUntil:
          (data['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'value': value,
      'maxDiscount': maxDiscount,
      'minFare': minFare,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'perUserLimit': perUserLimit,
      'firstRideOnly': firstRideOnly,
      'regions': regions,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }
}
