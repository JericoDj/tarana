import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapView extends StatefulWidget {
  final Position? initialPosition;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onCameraMove;
  final double defaultZoom;

  const MapView({
    super.key,
    this.initialPosition,
    this.markers,
    this.polylines,
    this.onMapCreated,
    this.onCameraMove,
    this.defaultZoom = 15.0,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _defaultManila = CameraPosition(
    target: LatLng(14.5995, 120.9842),
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    // If we have an initial position, use it. Otherwise fallback to default.
    final CameraPosition initialCameraPosition = widget.initialPosition != null
        ? CameraPosition(
            target: LatLng(
              widget.initialPosition!.latitude,
              widget.initialPosition!.longitude,
            ),
            zoom: widget.defaultZoom,
          )
        : _defaultManila;

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: initialCameraPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: false, // We'll build a custom one if needed
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      markers: widget.markers ?? <Marker>{},
      polylines: widget.polylines ?? <Polyline>{},
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
      onCameraMove: (CameraPosition position) {
        if (widget.onCameraMove != null) {
          widget.onCameraMove!(position.target);
        }
      },
    );
  }
}
