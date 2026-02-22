import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/booking_provider.dart';
import '../../providers/location_provider.dart';
import '../../../shared/enums/booking_status.dart';
import '../../widgets/map/map_view.dart';
import '../../widgets/map/marker_generator.dart';
import '../../widgets/common/gradient_button.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  BitmapDescriptor? _carIcon;
  String? _trackedDriverId;
  late LocationProvider _locationProvider;

  @override
  void initState() {
    super.initState();
    _locationProvider = context.read<LocationProvider>();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    final icon = await MarkerGenerator.createCustomMarker(
      iconData: Icons.directions_car_rounded,
      color: AppColors.primary,
      size: 80,
    );
    if (mounted) {
      setState(() {
        _carIcon = icon;
      });
    }
  }

  @override
  void dispose() {
    _locationProvider.stopWatchingDriver();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final activeBooking = bookingProvider.currentBooking;

    if (activeBooking == null) {
      // No active booking found, maybe it was completed/cancelled
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) {
          context.go('/home/rider');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Start tracking if a driver is assigned
    if (activeBooking.driverId != null &&
        _trackedDriverId != activeBooking.driverId) {
      _trackedDriverId = activeBooking.driverId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        locationProvider.startWatchingDriver(_trackedDriverId!);
      });
    }

    // Build markers
    final Set<Marker> markers = {};

    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(activeBooking.pickup.lat, activeBooking.pickup.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup'),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(activeBooking.dropoff.lat, activeBooking.dropoff.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Dropoff'),
      ),
    );

    if (_carIcon != null && locationProvider.trackedDriver != null) {
      final driver = locationProvider.trackedDriver!;
      markers.add(
        Marker(
          markerId: MarkerId(driver.uid),
          position: LatLng(driver.lat, driver.lng),
          icon: _carIcon!,
          anchor: const Offset(0.5, 0.5),
          rotation: driver.heading,
        ),
      );
    }

    // Build polylines
    final Set<Polyline> polylines = {};
    if (activeBooking.routePolyline.isNotEmpty) {
      final polylinePoints = PolylinePoints();
      final points = polylinePoints.decodePolyline(activeBooking.routePolyline);
      if (points.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.primary,
            width: 4,
            points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          ),
        );
      }
    }

    final isSearching =
        activeBooking.status == BookingStatus.searching ||
        activeBooking.status == BookingStatus.pending;

    final Position initialCameraPos = Position(
      longitude:
          locationProvider.trackedDriver?.lng ?? activeBooking.pickup.lng,
      latitude: locationProvider.trackedDriver?.lat ?? activeBooking.pickup.lat,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: locationProvider.trackedDriver?.heading ?? 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapView(
              initialPosition: initialCameraPos,
              markers: markers,
              polylines: polylines,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: isSearching
                    ? const SizedBox()
                    : CircleAvatar(
                        backgroundColor: AppColors.surface,
                        child: IconButton(
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () {},
                        ),
                      ),
              ),
            ),
          ),

          // Bottom Sheet Status
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isSearching) ...[
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Finding you a driver...',
                      style: AppTextStyles.h4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This usually takes about 2 minutes.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeBooking.status.label,
                              style: AppTextStyles.h4,
                            ),
                            Text(
                              activeBooking.driverId ?? 'Driver assigned',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Toyota Vios',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'White • ABC 1234',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                color: AppColors.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.phone_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  GradientButton(
                    text: 'Cancel Ride',
                    gradient: const LinearGradient(
                      colors: [Colors.grey, Colors.black45],
                    ),
                    onPressed: () async {
                      await bookingProvider.cancelBooking(
                        activeBooking.id,
                        "Changed mind",
                      );
                      if (context.mounted) {
                        context.go('/home/rider');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
