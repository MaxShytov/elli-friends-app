// lib/core/theme/app_theme.dart
// App theme configuration

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_text_styles.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme for the app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(120, 60),
        ),
      ),

      // Карточки
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // AppBar (если понадобится)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
