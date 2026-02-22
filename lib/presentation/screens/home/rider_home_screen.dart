import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/map/map_view.dart';
import '../../widgets/map/marker_generator.dart';
import '../../../shared/enums/user_role.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  BitmapDescriptor? _carIcon;
  bool _isWatchingDrivers = false;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final location = context.watch<LocationProvider>();

    if (location.currentPosition != null && !_isWatchingDrivers) {
      _isWatchingDrivers = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        location.startWatchingNearbyDrivers(location.currentPosition!);
      });
    }

    final Set<Marker> markers = {};
    if (_carIcon != null) {
      for (var driver in location.nearbyDrivers) {
        markers.add(
          Marker(
            markerId: MarkerId(driver.uid),
            position: LatLng(driver.lat, driver.lng),
            icon: _carIcon!,
            rotation: driver.heading,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Map
          Positioned.fill(
            child: MapView(
              initialPosition: location.currentPosition,
              markers: markers,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ─── Header Overlay ───
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
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
                                    (user?.displayName ?? 'U')
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hello, ${user?.displayName.split(' ').first ?? 'there'}!',
                                style: AppTextStyles.h4,
                              ),
                            ],
                          ),
                        ),
                        if (user?.isDriver ?? false)
                          IconButton(
                            icon: const Icon(Icons.swap_horiz_rounded),
                            tooltip: 'Switch to Driver',
                            onPressed: () {
                              location.stopWatchingNearbyDrivers();
                              auth.switchRole(UserRole.driver);
                              context.go('/driver');
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ─── Bottom Panel ───
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ─── Search Destination Card ───
                      GestureDetector(
                        onTap: () => context.push('/booking/search'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Where to?',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ─── Quick Actions ───
                      Text('Quick Actions', style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.bookmark_outline,
                            label: 'Saved\nPlaces',
                            onTap: () => context.push('/places'),
                          ),
                          const SizedBox(width: 8),
                          _QuickAction(
                            icon: Icons.contacts_outlined,
                            label: 'My\nContacts',
                            onTap: () => context.push('/contacts'),
                          ),
                          const SizedBox(width: 8),
                          _QuickAction(
                            icon: Icons.local_offer_outlined,
                            label: 'Promo\nCodes',
                            onTap: () => context.push('/promos'),
                          ),
                        ],
                      ),

                      // ─── Become a Driver Card ───
                      if (!(user?.isDriver ?? false)) ...[
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.premiumCard,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_car_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Become a Driver',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Earn on your own schedule',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/driver/apply'),
                                child: Container(
                                  width: 80,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
