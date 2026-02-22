import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/glass_card.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/map/map_view.dart';
import '../../widgets/map/marker_generator.dart';
import '../../../shared/enums/user_role.dart';
import '../../providers/location_provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final Set<Marker> _markers = {};
  BitmapDescriptor? _driverIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    final icon = await MarkerGenerator.createCustomMarker(
      iconData: Icons.directions_car_rounded,
      color: AppColors.primary,
      size: 100,
    );
    setState(() {
      _driverIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final location = context.watch<LocationProvider>();

    if (location.currentPosition != null && _driverIcon != null) {
      _markers.removeWhere((m) => m.markerId.value == 'driver_self');
      _markers.add(
        Marker(
          markerId: const MarkerId('driver_self'),
          position: LatLng(
            location.currentPosition!.latitude,
            location.currentPosition!.longitude,
          ),
          icon: _driverIcon!,
          anchor: const Offset(0.5, 0.5),
          rotation: location.heading,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Map Background ───
          Positioned.fill(
            child: MapView(
              initialPosition: location.currentPosition,
              markers: _markers,
            ),
          ),

          // ─── Foreground UI (Overlaid on Map) ───
          SafeArea(
            child: Column(
              children: [
                // Top Header (Status badge & toggle)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null,
                            child: user?.photoUrl == null
                                ? Text(
                                    (user?.displayName ?? 'D')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ExtendedHeaderInfo(isOnline: location.isOnline),
                        // Online Switch
                        Switch.adaptive(
                          value: location.isOnline,
                          activeTrackColor: AppColors.success,
                          onChanged: (v) => location.toggleOnlineStatus(),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Sheet-like Menu
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            location.isOnline
                                ? 'Looking for requests'
                                : 'You\'re Offline',
                            style: AppTextStyles.h3,
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz_rounded),
                            tooltip: 'Switch to Rider',
                            onPressed: () {
                              auth.switchRole(UserRole.rider);
                              context.go('/rider');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.route_rounded,
                            label: 'Today\'s Trips',
                            value: '0',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.attach_money_rounded,
                            label: 'Today\'s Earnings',
                            value: '₱0.00',
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Actions
                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.bar_chart_rounded,
                              label: 'Earnings',
                              onTap: () => context.push('/driver/earnings'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.person_outline,
                              label: 'Profile',
                              onTap: () => context.push('/profile'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onTap: () => context.push('/settings'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Incoming Request Overlay ───
          Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              final incomingBooking = bookingProvider.incomingBooking;
              if (incomingBooking == null) return const SizedBox.shrink();

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.airport_shuttle_rounded,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text('New Ride Request!', style: AppTextStyles.h2),
                            const SizedBox(height: 8),
                            Text(
                              'Pick up: ${incomingBooking.pickup.address}',
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drop off: ${incomingBooking.dropoff.address}',
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Est. Fare: ${incomingBooking.fare.currency} ${incomingBooking.fare.total.toStringAsFixed(2)}',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: bookingProvider.isLoading
                                        ? null
                                        : () {
                                            bookingProvider.rejectRide(
                                              incomingBooking.id,
                                            );
                                          },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      foregroundColor: AppColors.error,
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: bookingProvider.isLoading
                                        ? null
                                        : () async {
                                            await bookingProvider.acceptRide(
                                              incomingBooking.id,
                                            );
                                            // Optional: Navigate to trip screen if needed,
                                            // but TripScreen should auto-appear based on activeBookings if we implement it.
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: bookingProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Accept',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ExtendedHeaderInfo extends StatelessWidget {
  final bool isOnline;

  const ExtendedHeaderInfo({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap to go online',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          isOnline ? StatusBadge.online() : StatusBadge.offline(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
