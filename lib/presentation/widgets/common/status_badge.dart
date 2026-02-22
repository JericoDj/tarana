import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Status badge for driver/booking status display
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.fontSize = 12,
    this.padding,
  });

  /// Named constructors for common statuses
  factory StatusBadge.online() => const StatusBadge(
    text: 'Online',
    color: AppColors.statusOnline,
    textColor: Colors.white,
  );

  factory StatusBadge.offline() => const StatusBadge(
    text: 'Offline',
    color: AppColors.statusOffline,
    textColor: Colors.white,
  );

  factory StatusBadge.busy() => const StatusBadge(
    text: 'Busy',
    color: AppColors.statusBusy,
    textColor: Colors.white,
  );

  factory StatusBadge.pending() => const StatusBadge(
    text: 'Pending',
    color: AppColors.warning,
    textColor: Colors.white,
  );

  factory StatusBadge.approved() => const StatusBadge(
    text: 'Approved',
    color: AppColors.success,
    textColor: Colors.white,
  );

  factory StatusBadge.rejected() => const StatusBadge(
    text: 'Rejected',
    color: AppColors.error,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor ?? color ?? AppColors.primary,
        ),
      ),
    );
  }
}
