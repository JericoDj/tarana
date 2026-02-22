import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── Preferences ───
          Text('Preferences', style: AppTextStyles.h4),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: SwitchListTile.adaptive(
              title: const Text('Push Notifications'),
              subtitle: Text(
                'Receive ride updates and promos',
                style: AppTextStyles.caption,
              ),
              value: settings.notificationsEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => settings.setNotificationsEnabled(v),
            ),
          ),
          const SizedBox(height: 8),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: SwitchListTile.adaptive(
              title: const Text('Sound Effects'),
              subtitle: Text(
                'Play sounds for ride events',
                style: AppTextStyles.caption,
              ),
              value: settings.soundEffectsEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => settings.setSoundEffects(v),
            ),
          ),
          const SizedBox(height: 8),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: SwitchListTile.adaptive(
              title: const Text('Dark Mode'),
              subtitle: Text(
                'Switch to dark theme',
                style: AppTextStyles.caption,
              ),
              value: settings.darkModeEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => settings.setDarkMode(v),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Language ───
          Text('Language', style: AppTextStyles.h4),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.primary,
              ),
              title: const Text('App Language'),
              subtitle: Text(
                settings.languageLabel,
                style: AppTextStyles.caption,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showLanguagePicker(context, settings),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Driver Settings (if driver) ───
          if (context.watch<AuthProvider>().user?.roles.contains('driver') ??
              false) ...[
            Text('Driver Settings', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(4),
              child: SwitchListTile.adaptive(
                title: const Text('Auto-Accept Rides'),
                subtitle: Text(
                  'Automatically accept incoming ride requests',
                  style: AppTextStyles.caption,
                ),
                value: settings.autoAcceptRides,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => settings.setAutoAcceptRides(v),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ─── Account ───
          Text('Account', style: AppTextStyles.h4),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: ListTile(
              leading: const Icon(
                Icons.restore_rounded,
                color: AppColors.textSecondary,
              ),
              title: const Text('Reset Preferences'),
              subtitle: Text(
                'Restore all settings to defaults',
                style: AppTextStyles.caption,
              ),
              onTap: () => _showResetDialog(context, settings),
            ),
          ),
          const SizedBox(height: 8),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error),
              ),
              subtitle: Text(
                'Permanently delete your account after 30 days',
                style: AppTextStyles.caption,
              ),
              onTap: () => _showDeleteDialog(context),
            ),
          ),
          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.all(4),
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
              ),
              title: const Text('About Tarana'),
              subtitle: Text('Version 0.1.0', style: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Language', style: AppTextStyles.h4),
            ),
            _languageTile(ctx, settings, 'en', 'English', '🇺🇸'),
            _languageTile(ctx, settings, 'fil', 'Filipino', '🇵🇭'),
            _languageTile(ctx, settings, 'ceb', 'Cebuano', '🇵🇭'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(
    BuildContext context,
    SettingsProvider settings,
    String code,
    String label,
    String flag,
  ) {
    final isSelected = settings.language == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        settings.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Preferences?'),
        content: const Text(
          'All settings will be restored to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await settings.resetAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences reset')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Your account will be deactivated immediately and permanently deleted after 30 days. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              await auth.deleteAccount();
              if (context.mounted) context.go('/auth/login');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
