import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/enums/booking_status.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class AssignDriverScreen extends StatefulWidget {
  final String bookingId;

  const AssignDriverScreen({super.key, required this.bookingId});

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> {
  List<Map<String, dynamic>> _availableDrivers = [];
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableDrivers();
  }

  Future<void> _loadAvailableDrivers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('roles', arrayContains: 'driver')
          .where('isOnline', isEqualTo: true)
          .limit(20)
          .get();

      if (mounted) {
        setState(() {
          _availableDrivers = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'uid': doc.id,
              'displayName': data['displayName'] ?? 'Unknown Driver',
              'phone': data['phone'] ?? '',
              'vehicleInfo': data['vehicleInfo'] ?? {},
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load drivers';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _assignDriver(String driverUid) async {
    setState(() => _isAssigning = true);

    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.bookings)
          .doc(widget.bookingId)
          .update({
            'driverId': driverUid,
            'status': BookingStatus.driverAssigned.toFirestore(),
            'acceptedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver assigned successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAssigning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to assign driver')),
        );
      }
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
        title: const Text('Assign Driver'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium))
          : _availableDrivers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text('No drivers available', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    'Online drivers will appear here',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #${widget.bookingId.substring(0, 8)}',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select an available driver to assign',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _availableDrivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final driver = _availableDrivers[index];
                      final vehicle =
                          driver['vehicleInfo'] as Map<String, dynamic>;
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight.withAlpha(
                                (0.2 * 255).round(),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver['displayName'] as String,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (vehicle.isNotEmpty)
                                    Text(
                                      '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'
                                          .trim(),
                                      style: AppTextStyles.caption,
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              height: 36,
                              child: GradientButton(
                                text: 'Assign',
                                isLoading: _isAssigning,
                                onPressed: () =>
                                    _assignDriver(driver['uid'] as String),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
