import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../providers/auth_provider.dart';
import '../../providers/promo_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_button.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<PromoProvider>().loadReferralData(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final referralCode = user?.referralCode ?? '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Refer a Friend'),
      ),
      body: Consumer<PromoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppGradients.premiumCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.card_giftcard_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Share the love!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invite friends and earn ₱50 after their first trip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Referral code card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Your referral code',
                        style: AppTextStyles.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        referralCode,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: referralCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied!')),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded),
                              label: const Text('Copy'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              text: 'Share',
                              icon: Icons.share_rounded,
                              onPressed: () {
                                Share.share(
                                  'Join me on Tarana! Use my referral code $referralCode to get a discount on your first ride. Download now!',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    _buildStatCard(
                      'Referrals',
                      '${provider.myReferrals.length}',
                      Icons.people_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Earned',
                      '₱${provider.totalRewards.toStringAsFixed(0)}',
                      Icons.monetization_on_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Referral list
                if (provider.myReferrals.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Your Referrals', style: AppTextStyles.h4),
                  ),
                  const SizedBox(height: 12),
                  ...provider.myReferrals.map(
                    (referral) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: referral.isRewarded
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                              child: Icon(
                                referral.isRewarded
                                    ? Icons.check_circle_rounded
                                    : Icons.hourglass_top_rounded,
                                color: referral.isRewarded
                                    ? AppColors.success
                                    : AppColors.warning,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    referral.refereeRole == 'rider'
                                        ? 'Rider referral'
                                        : 'Driver referral',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    referral.isRewarded
                                        ? 'Rewarded'
                                        : referral.status == 'trip_completed'
                                        ? 'Trip completed'
                                        : 'Pending first trip',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₱${referral.rewardAmount.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: referral.isRewarded
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
