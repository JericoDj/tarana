import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../../../shared/enums/booking_status.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../widgets/common/glass_card.dart';

class ActiveTripsScreen extends StatefulWidget {
  const ActiveTripsScreen({super.key});

  @override
  State<ActiveTripsScreen> createState() => _ActiveTripsScreenState();
}

class _ActiveTripsScreenState extends State<ActiveTripsScreen> {
  StreamSubscription? _subscription;
  List<BookingModel> _activeTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _watchTrips();
  }

  void _watchTrips() {
    _subscription = FirebaseFirestore.instance
        .collection(FirestorePaths.bookings)
        .where(
          'status',
          whereIn: [
            BookingStatus.searching.toFirestore(),
            BookingStatus.driverAssigned.toFirestore(),
            BookingStatus.driverArriving.toFirestore(),
            BookingStatus.arrived.toFirestore(),
            BookingStatus.inProgress.toFirestore(),
          ],
        )
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (mounted) {
              setState(() {
                _activeTrips = snapshot.docs
                    .map((doc) => BookingModel.fromFirestore(doc))
                    .toList();
                _isLoading = false;
              });
            }
          },
          onError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.searching:
        return AppColors.warning;
      case BookingStatus.driverAssigned:
      case BookingStatus.driverArriving:
        return AppColors.info;
      case BookingStatus.arrived:
        return Colors.orange;
      case BookingStatus.inProgress:
        return AppColors.success;
      default:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.searching:
        return 'SEARCHING';
      case BookingStatus.driverAssigned:
        return 'ASSIGNED';
      case BookingStatus.driverArriving:
        return 'ARRIVING';
      case BookingStatus.arrived:
        return 'ARRIVED';
      case BookingStatus.inProgress:
        return 'IN PROGRESS';
      default:
        return status.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Active Trips'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_activeTrips.length} active',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeTrips.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text('No active trips', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    'All rides will show here in real-time',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _activeTrips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = _activeTrips[index];
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Ride #${trip.id.substring(0, 8)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                trip.status,
                              ).withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _statusLabel(trip.status),
                              style: AppTextStyles.caption.copyWith(
                                color: _statusColor(trip.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Locations
                      Row(
                        children: [
                          const Icon(
                            Icons.my_location_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              trip.pickup.address,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              trip.dropoff.address,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${trip.fare.total.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            trip.paymentMethod.label,
                            style: AppTextStyles.caption,
                          ),
                          if (trip.driverId != null)
                            Text(
                              'Driver: ${trip.driverId!.substring(0, 6)}...',
                              style: AppTextStyles.caption,
                            )
                          else if (trip.status == BookingStatus.searching)
                            GestureDetector(
                              onTap: () => context.push(
                                '/admin/assign-driver/${trip.id}',
                              ),
                              child: Text(
                                'Assign →',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
