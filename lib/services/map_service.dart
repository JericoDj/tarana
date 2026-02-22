import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../core/constants/app_constants.dart';

class RouteDetails {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final int distanceValue; // in meters
  final String durationText;
  final int durationValue; // in seconds
  final LatLng boundsNortheast;
  final LatLng boundsSouthwest;

  RouteDetails({
    required this.polylinePoints,
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
    required this.boundsNortheast,
    required this.boundsSouthwest,
  });
}

class MapService {
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  Future<RouteDetails?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String url =
        '$_baseUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${AppConstants.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if ((data['routes'] as List).isEmpty) {
          return null;
        }

        final route = data['routes'][0];
        final leg = route['legs'][0];

        // Decode Polyline Points
        final String encodedPolyline = route['overview_polyline']['points'];
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(
          encodedPolyline,
        );
        List<LatLng> points = decodedPoints
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        // Get bounds
        final bounds = route['bounds'];
        final northeast = LatLng(
          bounds['northeast']['lat'],
          bounds['northeast']['lng'],
        );
        final southwest = LatLng(
          bounds['southwest']['lat'],
          bounds['southwest']['lng'],
        );

        return RouteDetails(
          polylinePoints: points,
          distanceText: leg['distance']['text'],
          distanceValue: leg['distance']['value'],
          durationText: leg['duration']['text'],
          durationValue: leg['duration']['value'],
          boundsNortheast: northeast,
          boundsSouthwest: southwest,
        );
      } else {
        throw Exception('Failed to load directions');
      }
    } catch (e) {
      debugPrint('Error getting directions: $e');
      return null;
    }
  }
}
