import 'package:flutter/material.dart';

/// Tarana color palette
///
/// Based on: Tomato · Mustard · Pacific Blue · Alabaster Grey · Ghost White
class AppColors {
  AppColors._();

  // ─── Primary Brand (Pacific Blue) ───
  static const Color primary = Color(0xFF009FB7);
  static const Color primaryLight = Color(0xFF4DC5D6);
  static const Color primaryDark = Color(0xFF007A8C);

  // ─── Accent (Tomato) ───
  static const Color accent = Color(0xFF23A23F);
  static const Color accentLight = Color(0xFFFF7F7E);
  static const Color accentDark = Color(0xFFD63534);

  // ─── Secondary (Mustard) ───
  static const Color secondary = Color(0xFFFED766);
  static const Color secondaryLight = Color(0xFFFEE59A);
  static const Color secondaryDark = Color(0xFFE5BF4E);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFED766); // Mustard doubles as warning
  static const Color error = Color(0xFFFE4A49); // Tomato doubles as error
  static const Color info = Color(0xFF009FB7); // Pacific Blue doubles as info

  // ─── Neutral / Surface Colors ───
  static const Color background = Color(0xFFF4F4F8); // Ghost White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE6E6EA); // Alabaster Grey
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ─── Text Colors ───
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ─── Border / Divider ───
  static const Color border = Color(0xFFE6E6EA); // Alabaster Grey
  static const Color divider = Color(0xFFE6E6EA);

  // ─── Glassmorphism ───
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassShadow = Color(0x0A000000);

  // ─── Driver Status Colors ───
  static const Color statusOnline = Color(0xFF2ECC71);
  static const Color statusOffline = Color(0xFF9CA3AF);
  static const Color statusBusy = Color(0xFFFED766); // Mustard
  static const Color statusOnTrip = Color(0xFF009FB7); // Pacific Blue
}
