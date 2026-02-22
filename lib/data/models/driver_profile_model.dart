import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/enums/verification_status.dart';

/// Driver profile data model with vehicle & license info
class DriverProfileModel {
  final String uid;
  final String vehicleMake;
  final String vehicleModel;
  final String plateNumber;
  final String vehicleColor;
  final String vehicleType;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final VerificationStatus verificationStatus;
  final Map<String, String> documents;
  final double rating;
  final int totalTrips;
  final double totalEarnings;
  final DateTime applicationDate;
  final String? approvedBy;
  final DateTime? approvedAt;

  const DriverProfileModel({
    required this.uid,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.plateNumber,
    required this.vehicleColor,
    required this.vehicleType,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.verificationStatus = VerificationStatus.pending,
    this.documents = const {},
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalEarnings = 0.0,
    required this.applicationDate,
    this.approvedBy,
    this.approvedAt,
  });

  bool get isApproved => verificationStatus == VerificationStatus.approved;

  factory DriverProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverProfileModel(
      uid: doc.id,
      vehicleMake: data['vehicleMake'] ?? '',
      vehicleModel: data['vehicleModel'] ?? '',
      plateNumber: data['plateNumber'] ?? '',
      vehicleColor: data['vehicleColor'] ?? '',
      vehicleType: data['vehicleType'] ?? 'sedan',
      licenseNumber: data['licenseNumber'] ?? '',
      licenseExpiry:
          (data['licenseExpiry'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verificationStatus: VerificationStatus.fromString(
        data['verificationStatus'] ?? 'pending',
      ),
      documents: Map<String, String>.from(data['documents'] ?? {}),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: data['totalTrips'] ?? 0,
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      applicationDate:
          (data['applicationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedBy: data['approvedBy'],
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'plateNumber': plateNumber,
      'vehicleColor': vehicleColor,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'licenseExpiry': Timestamp.fromDate(licenseExpiry),
      'verificationStatus': verificationStatus.name,
      'documents': documents,
      'rating': rating,
      'totalTrips': totalTrips,
      'totalEarnings': totalEarnings,
      'applicationDate': Timestamp.fromDate(applicationDate),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }
}
