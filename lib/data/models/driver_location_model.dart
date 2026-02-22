import '../../shared/enums/driver_status.dart';

/// Driver location model for Firebase RTDB
class DriverLocationModel {
  final String uid;
  final double lat;
  final double lng;
  final double heading;
  final double speed;
  final String geohash;
  final DriverStatus status;
  final int updatedAt;

  const DriverLocationModel({
    required this.uid,
    required this.lat,
    required this.lng,
    this.heading = 0.0,
    this.speed = 0.0,
    this.geohash = '',
    this.status = DriverStatus.offline,
    required this.updatedAt,
  });

  factory DriverLocationModel.fromRtdb(String uid, Map<dynamic, dynamic> data) {
    return DriverLocationModel(
      uid: uid,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      heading: (data['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (data['speed'] as num?)?.toDouble() ?? 0.0,
      geohash: data['geohash'] ?? '',
      status: DriverStatus.fromString(data['status'] ?? 'offline'),
      updatedAt: data['updatedAt'] ?? 0,
    );
  }

  Map<String, dynamic> toRtdb() {
    return {
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
      'geohash': geohash,
      'status': status.toFirestore(),
      'updatedAt': updatedAt,
    };
  }
}
