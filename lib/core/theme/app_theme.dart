import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_config.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(const ColorScheme.light(
        primary: AppColors.deepBlue,
        secondary: AppColors.orange,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ));

  static ThemeData get dark => _build(const ColorScheme.dark(
        primary: AppColors.orange,
        secondary: AppColors.deepBlue,
        surface: Color(0xFF121212),
        onSurface: Colors.white,
      ));

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : AppColors.textPrimary;
    final surf = scheme.surface;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF1a1a1a) : AppColors.lightGrey,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontFamily: AppConfig.fontInter,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: baseColor,
        ),
        titleMedium: TextStyle(
          fontFamily: AppConfig.fontInter,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: baseColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: AppConfig.fontInter,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: baseColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: AppConfig.fontInter,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: baseColor,
        ),
        labelLarge: TextStyle(
          fontFamily: AppConfig.fontInter,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: baseColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontFamily: AppConfig.fontInter, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surf,
          foregroundColor: scheme.primary,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontFamily: AppConfig.fontInter, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => AppColors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : isDark ? const Color(0xFF555555) : AppColors.lightGrey,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: isDark ? const Color(0xFF555555) : AppColors.lightGrey,
        thumbColor: scheme.primary,
        trackHeight: 4,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
    );
  }
}