import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/enums/verification_status.dart';

/// Driver application model for the approval workflow
class DriverApplicationModel {
  final String id;
  final String uid;
  final VerificationStatus status;
  final Map<String, dynamic> vehicleInfo;
  final Map<String, String> documents;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const DriverApplicationModel({
    required this.id,
    required this.uid,
    this.status = VerificationStatus.pending,
    required this.vehicleInfo,
    this.documents = const {},
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
  });

  bool get isPending => status == VerificationStatus.pending;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;

  factory DriverApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverApplicationModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      status: VerificationStatus.fromString(data['status'] ?? 'pending'),
      vehicleInfo: Map<String, dynamic>.from(data['vehicleInfo'] ?? {}),
      documents: Map<String, String>.from(data['documents'] ?? {}),
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedBy: data['reviewedBy'],
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'status': status.name,
      'vehicleInfo': vehicleInfo,
      'documents': documents,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }
}
