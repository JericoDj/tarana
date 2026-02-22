import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/driver_location_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../services/location_service.dart';
import '../../shared/enums/driver_status.dart';
import 'auth_provider.dart';

class LocationProvider extends ChangeNotifier {
  final LocationRepository _repository;
  final LocationService _locationService;
  final AuthProvider _authProvider;

  LocationProvider({
    required AuthProvider authProvider,
    LocationRepository? repository,
    LocationService? locationService,
  }) : _authProvider = authProvider,
       _repository = repository ?? LocationRepository(),
       _locationService = locationService ?? LocationService();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  double _heading = 0.0;
  double get heading => _heading;

  List<DriverLocationModel> _nearbyDrivers = [];
  List<DriverLocationModel> get nearbyDrivers => _nearbyDrivers;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<DriverLocationModel>>? _nearbyDriversSubscription;

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _nearbyDriversSubscription?.cancel();
    super.dispose();
  }

  /// Toggle driver online status
  Future<void> toggleOnlineStatus() async {
    final uid = _authProvider.user?.uid;
    if (uid == null) return;

    if (_isOnline) {
      await goOffline(uid);
    } else {
      await goOnline(uid);
    }
  }

  Future<void> goOnline(String uid) async {
    try {
      // 1. Get initial location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        throw Exception('Could not get actual location');
      }

      _currentPosition = position;
      _heading = position.heading;

      // 2. Set RTDB state to online
      final locationModel = DriverLocationModel(
        uid: uid,
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
        speed: position.speed,
        geohash: '', // Calculate later if doing geoqueries via GeoFire
        status: DriverStatus.online,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _repository.setDriverOnline(locationModel);
      _isOnline = true;
      notifyListeners();

      // 3. Start watching location and broadcasting to RTDB
      _startTracking(uid);
    } catch (e) {
      // Handle error (e.g. permission denied)
      debugPrint('Error going online: $e');
    }
  }

  Future<void> goOffline(String uid) async {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      await _repository.setDriverOffline(uid);
    } catch (e) {
      debugPrint('Error going offline: $e');
    }

    _isOnline = false;
    notifyListeners();
  }

  void _startTracking(String uid) {
    _positionSubscription?.cancel();

    _positionSubscription = _locationService.getPositionStream().listen(
      (Position position) {
        _currentPosition = position;
        _heading = position.heading;
        notifyListeners();

        // Broadcast update to RTDB
        _repository
            .updateDriverLocation(uid, position, _heading)
            .catchError((e) => debugPrint('Broadcast failed: $e'));
      },
      onError: (e) {
        debugPrint('Location stream error: $e');
        // Depending on the error, might want to go offline automatically
      },
    );
  }

  /// Start watching nearby drivers for a rider
  void startWatchingNearbyDrivers(Position center, {double radiusKm = 10.0}) {
    _nearbyDriversSubscription?.cancel();
    _nearbyDriversSubscription = _repository
        .getNearbyDriversStream(center, radiusKm)
        .listen(
          (drivers) {
            _nearbyDrivers = drivers;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error observing nearby drivers: $e');
          },
        );
  }

  void stopWatchingNearbyDrivers() {
    _nearbyDriversSubscription?.cancel();
    _nearbyDriversSubscription = null;
    _nearbyDrivers = [];
    notifyListeners();
  }

  DriverLocationModel? _trackedDriver;
  DriverLocationModel? get trackedDriver => _trackedDriver;

  StreamSubscription<DriverLocationModel?>? _trackedDriverSubscription;

  void startWatchingDriver(String uid) {
    _trackedDriverSubscription?.cancel();
    _trackedDriverSubscription = _repository
        .getDriverLocationStream(uid)
        .listen((driverData) {
          _trackedDriver = driverData;
          notifyListeners();
        });
  }

  void stopWatchingDriver() {
    _trackedDriverSubscription?.cancel();
    _trackedDriverSubscription = null;
    _trackedDriver = null;
    notifyListeners();
  }
}
