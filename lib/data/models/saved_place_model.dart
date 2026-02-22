import 'package:cloud_firestore/cloud_firestore.dart';

/// Saved place model (home, work, custom locations)
class SavedPlaceModel {
  final String id;
  final String label;
  final String address;
  final double lat;
  final double lng;
  final String? googlePlaceId;
  final DateTime createdAt;

  const SavedPlaceModel({
    required this.id,
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
    this.googlePlaceId,
    required this.createdAt,
  });

  factory SavedPlaceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedPlaceModel(
      id: doc.id,
      label: data['label'] ?? '',
      address: data['address'] ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      googlePlaceId: data['googlePlaceId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
      'googlePlaceId': googlePlaceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
