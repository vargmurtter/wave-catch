import 'package:flutter/material.dart';

import 'package:music_player/ui/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.accent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      dividerColor: AppColors.divider,
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.surfaceElevated,
        thumbColor: AppColors.textPrimary,
        overlayColor: Color(0x33FF4848),
        trackHeight: 4,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }
}
