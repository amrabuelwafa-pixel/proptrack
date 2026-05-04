import 'package:flutter/material.dart';
import 'package:proptrack/core/theme/app_colors.dart';
import 'package:proptrack/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      hintStyle: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
        height: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(52),
        textStyle: AppTextStyles.button.copyWith(
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(52),
        textStyle: AppTextStyles.button.copyWith(
          color: AppColors.primary,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.link.copyWith(
          color: AppColors.primary,
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayTitle.copyWith(
        color: AppColors.textPrimary,
      ),
      displayMedium: AppTextStyles.headline.copyWith(
        color: AppColors.textPrimary,
      ),
      displaySmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.textPrimary,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.textPrimary,
      ),
      titleLarge: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
      ),
      titleMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      titleSmall: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      bodyLarge: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
      ),
      bodyMedium: AppTextStyles.bodyRegular.copyWith(
        color: AppColors.textPrimary,
      ),
      bodySmall: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
      ),
      labelLarge: AppTextStyles.button.copyWith(
        color: Colors.white,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      labelSmall: AppTextStyles.captionSmall.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDarkColors.primary,
      brightness: Brightness.dark,
      primary: AppDarkColors.primary,
      secondary: AppDarkColors.accent,
      surface: AppDarkColors.surface,
      surfaceContainerHighest: AppDarkColors.background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppDarkColors.textPrimary,
      error: AppDarkColors.error,
    ),
    scaffoldBackgroundColor: AppDarkColors.background,
    dividerColor: AppDarkColors.divider,
    cardTheme: CardThemeData(
      color: AppDarkColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppDarkColors.divider),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDarkColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.divider, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      hintStyle: AppTextStyles.caption.copyWith(
        color: AppDarkColors.textSecondary,
      ),
      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppDarkColors.error,
        height: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(52),
        textStyle: AppTextStyles.button.copyWith(
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppDarkColors.primary,
        side: const BorderSide(color: AppDarkColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(52),
        textStyle: AppTextStyles.button.copyWith(
          color: AppDarkColors.primary,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppDarkColors.primary,
        textStyle: AppTextStyles.link.copyWith(
          color: AppDarkColors.primary,
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayTitle.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      displayMedium: AppTextStyles.headline.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      displaySmall: AppTextStyles.headlineSmall.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      titleLarge: AppTextStyles.body.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      titleMedium: AppTextStyles.labelMedium.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      titleSmall: AppTextStyles.labelMedium.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      bodyLarge: AppTextStyles.body.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      bodyMedium: AppTextStyles.bodyRegular.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      bodySmall: AppTextStyles.caption.copyWith(
        color: AppDarkColors.textSecondary,
      ),
      labelLarge: AppTextStyles.button.copyWith(
        color: Colors.white,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppDarkColors.textPrimary,
      ),
      labelSmall: AppTextStyles.captionSmall.copyWith(
        color: AppDarkColors.textSecondary,
      ),
    ),
  );
}
