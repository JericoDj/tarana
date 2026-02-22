import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/driver_application_model.dart';
import '../../../data/repositories/driver_application_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class DriverApprovalsScreen extends StatefulWidget {
  const DriverApprovalsScreen({super.key});

  @override
  State<DriverApprovalsScreen> createState() => _DriverApprovalsScreenState();
}

class _DriverApprovalsScreenState extends State<DriverApprovalsScreen> {
  final DriverApplicationRepository _repository = DriverApplicationRepository();
  List<DriverApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final apps = await _repository.getPendingApplications();
      if (mounted) {
        setState(() {
          _applications = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load applications';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reviewApplication(
    DriverApplicationModel app,
    String status, {
    String? reason,
  }) async {
    final auth = context.read<AuthProvider>();
    try {
      await _repository.reviewApplication(
        uid: app.uid,
        status: status,
        reviewerUid: auth.user?.uid ?? '',
        rejectionReason: reason,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Driver approved!'
                  : 'Application rejected',
            ),
          ),
        );
        _loadApplications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update application')),
        );
      }
    }
  }

  void _showRejectDialog(DriverApplicationModel app) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Application'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reviewApplication(app, 'rejected', reason: controller.text);
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
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
        title: const Text('Driver Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium))
          : _applications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text('No pending applications', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    'Driver applications will appear here for review',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadApplications,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = _applications[index];
                  return _ApplicationCard(
                    application: app,
                    onApprove: () => _reviewApplication(app, 'approved'),
                    onReject: () => _showRejectDialog(app),
                  );
                },
              ),
            ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final DriverApplicationModel application;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApplicationCard({
    required this.application,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final vehicle = application.vehicleInfo;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withAlpha(
                  (0.2 * 255).round(),
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UID: ${application.uid.substring(0, 8)}...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Submitted ${_formatDate(application.submittedAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PENDING',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Vehicle info
          if (vehicle.isNotEmpty) ...[
            Text(
              'Vehicle',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''} (${vehicle['year'] ?? ''})',
              style: AppTextStyles.caption,
            ),
            Text(
              'Plate: ${vehicle['plateNumber'] ?? 'N/A'}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
          ],

          // Documents
          if (application.documents.isNotEmpty) ...[
            Text(
              'Documents',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: application.documents.keys.map((doc) {
                return Chip(
                  avatar: const Icon(Icons.description, size: 16),
                  label: Text(doc, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: 'Approve',
                  icon: Icons.check,
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
