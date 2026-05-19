import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1A2B4A);
  static const Color primaryDark = Color(0xFF031634);
  static const Color primaryLight = Color(0xFF2E4A7C);

  // Surfaces
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF2F3F7);

  // Accents
  static const Color gold = Color(0xFFFFD700);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Lines
  static const Color outline = Color(0xFFE2E8F0);

  // Status — success
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);

  // Status — danger
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFF991B1B);

  // Status — warning
  static const Color warning = Color(0xFFE9C400);
  static const Color warningBg = Color(0xFFFEF9C3);
  static const Color warningText = Color(0xFF854D0E);

  // Charts
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartBlueBg = Color(0xFFDBEAFE);

  // Legacy aliases — kept so existing call sites compile. Migrate to
  // the canonical token and the alias can be removed.
  @Deprecated('Use AppColors.primaryLight instead')
  static const Color accent = primaryLight;
  @Deprecated('Use AppColors.outline instead')
  static const Color divider = outline;
  @Deprecated('Use AppColors.danger instead')
  static const Color error = danger;
  @Deprecated('Use AppColors.textMuted instead')
  static const Color textSecondary = textMuted;
  @Deprecated('Use AppColors.outline instead')
  static const Color disabled = outline;
}

abstract final class AppDarkColors {
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1A2E42);
  static const Color surfaceAlt = Color(0xFF162534);
  static const Color primary = Color(0xFF2E86AB);
  static const Color accent = Color(0xFF5BA3C9);
  static const Color textPrimary = Color(0xFFE8EDF2);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color divider = Color(0xFF2D4A6B);
  static const Color error = Color(0xFFEF5350);
  static const Color disabled = Color(0xFF425B7F);
  static const Color success = Color(0xFF10B981);
}
