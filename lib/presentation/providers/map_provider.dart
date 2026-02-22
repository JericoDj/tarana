import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/map_service.dart';
import '../../core/theme/app_colors.dart';

class MapProvider with ChangeNotifier {
  final MapService _mapService = MapService();

  RouteDetails? _currentRoute;
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;
  String? _routeError;

  RouteDetails? get currentRoute => _currentRoute;
  Set<Polyline> get polylines => _polylines;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get routeError => _routeError;

  Future<void> drawRoute(LatLng origin, LatLng destination) async {
    _isLoadingRoute = true;
    _routeError = null;
    notifyListeners();

    try {
      final routeDetails = await _mapService.getDirections(
        origin: origin,
        destination: destination,
      );

      if (routeDetails != null) {
        _currentRoute = routeDetails;

        // Create polyline
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: AppColors.primary,
          width: 5,
          points: routeDetails.polylinePoints,
        );

        _polylines = {polyline};
      } else {
        _routeError = 'No route found.';
      }
    } catch (e) {
      _routeError = 'Failed to get route: $e';
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void clearRoute() {
    _currentRoute = null;
    _polylines.clear();
    _routeError = null;
    notifyListeners();
  }
}
