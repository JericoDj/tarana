import 'package:cloud_firestore/cloud_firestore.dart';

/// Contact model for emergency contacts and saved passengers
class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String type; // 'emergency' or 'passenger'
  final String? relationship;
  final DateTime createdAt;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.relationship,
    required this.createdAt,
  });

  bool get isEmergency => type == 'emergency';
  bool get isPassenger => type == 'passenger';

  factory ContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      type: data['type'] ?? 'emergency',
      relationship: data['relationship'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'type': type,
      'relationship': relationship,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
