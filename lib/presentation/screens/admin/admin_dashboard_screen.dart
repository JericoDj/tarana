import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/common/glass_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Management', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _AdminTile(
              icon: Icons.verified_user_outlined,
              label: 'Driver Approvals',
              subtitle: 'Review pending applications',
              onTap: () => context.push('/admin/driver-approvals'),
            ),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.map_outlined,
              label: 'Active Trips',
              subtitle: 'Monitor ongoing rides',
              onTap: () => context.push('/admin/active-trips'),
            ),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.people_outline,
              label: 'User Management',
              subtitle: 'Manage users and roles',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _AdminTile(
              icon: Icons.local_offer_outlined,
              label: 'Promo Campaigns',
              subtitle: 'Create and manage promos',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _AdminTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
