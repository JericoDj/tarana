import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/driver_location_model.dart';
import '../datasources/remote/rtdb_source.dart';
import '../../shared/enums/driver_status.dart';

class LocationRepository {
  final RtdbSource _rtdbSource;

  LocationRepository({RtdbSource? rtdbSource})
    : _rtdbSource = rtdbSource ?? RtdbSource();

  static const String _driversPath = 'drivers';

  /// Go online
  Future<void> setDriverOnline(DriverLocationModel location) async {
    final path = '$_driversPath/${location.uid}';
    final data = location.toRtdb();

    // 1. Set the data
    await _rtdbSource.setData(path, data);

    // 2. Set onDisconnect handler so the driver goes offline if connection drops
    final offlineData = {
      'status': DriverStatus.offline.toFirestore(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _rtdbSource.setOnDisconnect(path, offlineData);
  }

  /// Update location while online
  Future<void> updateDriverLocation(
    String uid,
    Position position,
    double heading,
  ) async {
    final path = '$_driversPath/$uid';
    final update = {
      'lat': position.latitude,
      'lng': position.longitude,
      'heading': heading,
      'speed': position.speed,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _rtdbSource.updateData(path, update);
  }

  /// Change driver status (e.g. from online to on_trip)
  Future<void> updateDriverStatus(String uid, DriverStatus status) async {
    final path = '$_driversPath/$uid';
    final update = {
      'status': status.toFirestore(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _rtdbSource.updateData(path, update);
  }

  /// Go offline
  Future<void> setDriverOffline(String uid) async {
    final path = '$_driversPath/$uid';
    await _rtdbSource.cancelOnDisconnect(path);
    final offlineData = {
      'status': DriverStatus.offline.toFirestore(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _rtdbSource.updateData(path, offlineData);
  }

  /// Get nearby online drivers
  Stream<List<DriverLocationModel>> getNearbyDriversStream(
    Position riderPosition,
    double radiusKm,
  ) {
    return _rtdbSource.watchPath(_driversPath).map((event) {
      if (event.snapshot.value == null) return [];

      final Map<dynamic, dynamic> driversMap =
          event.snapshot.value as Map<dynamic, dynamic>;

      final List<DriverLocationModel> nearbyDrivers = [];

      driversMap.forEach((key, value) {
        final driverData = value as Map<dynamic, dynamic>;
        final model = DriverLocationModel.fromRtdb(key, driverData);

        // Filter only online drivers
        if (model.status == DriverStatus.online) {
          double distanceInMeters = Geolocator.distanceBetween(
            riderPosition.latitude,
            riderPosition.longitude,
            model.lat,
            model.lng,
          );

          if (distanceInMeters <= (radiusKm * 1000)) {
            nearbyDrivers.add(model);
          }
        }
      });

      return nearbyDrivers;
    });
  }

  /// Get specific driver location stream
  Stream<DriverLocationModel?> getDriverLocationStream(String uid) {
    return _rtdbSource.watchPath('$_driversPath/$uid').map((event) {
      if (event.snapshot.value == null) return null;
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return DriverLocationModel.fromRtdb(uid, data);
    });
  }
}
