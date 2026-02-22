import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradient definitions based on the Tarana palette
class AppGradients {
  AppGradients._();

  /// Primary brand gradient (Pacific Blue → Tomato)
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accent],
  );

  /// Subtle background gradient (Ghost White → Alabaster Grey)
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F4F8), Color(0xFFE6E6EA)],
  );

  /// Premium card gradient (Pacific Blue → Tomato → Mustard)
  static const LinearGradient premiumCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF009FB7), Color(0xFFFE4A49), Color(0xFFFED766)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Warm gradient (Tomato → Mustard)
  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFE4A49), Color(0xFFFED766)],
  );

  /// Success gradient
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2ECC71), Color(0xFF00D9A6)],
  );

  /// Glass overlay gradient
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x30FFFFFF), Color(0x10FFFFFF)],
  );

  /// Shimmer gradient for loading states
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6E6EA), Color(0xFFF4F4F8), Color(0xFFE6E6EA)],
    stops: [0.0, 0.5, 1.0],
  );

  /// Dark mode primary gradient
  static const LinearGradient darkPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF004F5A), Color(0xFF1A1D2E)],
  );

  /// Info / teal gradient (for trip cards, stats)
  static const LinearGradient info = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF009FB7), Color(0xFF007A8C)],
  );

  /// Radial glow for decorative elements
  static const RadialGradient glow = RadialGradient(
    colors: [Color(0x20009FB7), Color(0x00009FB7)],
    radius: 1.0,
  );

  /// Mesh-style multi-color gradient for premium sections
  static const LinearGradient mesh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF009FB7), // Pacific Blue
      Color(0xFFFE4A49), // Tomato
      Color(0xFFFED766), // Mustard
      Color(0xFF009FB7), // Pacific Blue
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );
}
