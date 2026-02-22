import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? 'User', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),

            // Info cards
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user?.phone ?? 'Not set',
            ),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: user?.activeRole.label ?? 'Rider',
            ),
            _InfoRow(
              icon: Icons.card_giftcard_outlined,
              label: 'Referral Code',
              value: user?.referralCode ?? '—',
            ),

            const SizedBox(height: 24),

            // Menu items
            _MenuItem(
              icon: Icons.bookmark_outline,
              label: 'Saved Places',
              onTap: () => context.push('/places'),
            ),
            _MenuItem(
              icon: Icons.contacts_outlined,
              label: 'Emergency Contacts',
              onTap: () => context.push('/contacts'),
            ),
            _MenuItem(
              icon: Icons.local_offer_outlined,
              label: 'Promo Codes',
              onTap: () => context.push('/promos'),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push('/settings'),
            ),

            const SizedBox(height: 24),

            // Sign out
            GlassCard(
              padding: const EdgeInsets.all(4),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                  context.go('/auth/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.labelMedium),
            const Spacer(),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(4),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
