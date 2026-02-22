import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../../../shared/enums/booking_status.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<BookingModel> _rides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestorePaths.bookings)
          .where('riderId', isEqualTo: uid)
          .where(
            'status',
            whereIn: [
              BookingStatus.completed.toFirestore(),
              BookingStatus.cancelled.toFirestore(),
            ],
          )
          .orderBy('requestedAt', descending: true)
          .limit(50)
          .get();

      if (mounted) {
        setState(() {
          _rides = snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load ride history';
          _isLoading = false;
        });
      }
    }
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
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
        title: const Text('Ride History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _rides.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text('No rides yet', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed rides will appear here',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _rides.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ride = _rides[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(ride.requestedAt),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  ride.status,
                                ).withAlpha((0.15 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusLabel(ride.status),
                                style: AppTextStyles.caption.copyWith(
                                  color: _statusColor(ride.status),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                Container(
                                  width: 1.5,
                                  height: 20,
                                  color: AppColors.border,
                                ),
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ride.pickup.address,
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    ride.dropoff.address,
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 4),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${ride.fare.total.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.route_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ride.distanceKm.toStringAsFixed(1)} km',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                            Text(
                              ride.paymentMethod.label,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
