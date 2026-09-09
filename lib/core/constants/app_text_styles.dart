import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_config.dart';

abstract class AppTextStyles {
  static const FontWeight _w400 = FontWeight.w400;
  static const FontWeight _w500 = FontWeight.w500;
  static const FontWeight _w600 = FontWeight.w600;
  static const FontWeight _w700 = FontWeight.w700;
  static const FontWeight _w900 = FontWeight.w900;

  static final TextStyle titleLarge = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 28,
    fontWeight: _w900,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static final TextStyle titleMedium = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 20,
    fontWeight: _w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle subtitle = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 16,
    fontWeight: _w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle body = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 15,
    fontWeight: _w400,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyBold = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 15,
    fontWeight: _w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle label = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 13,
    fontWeight: _w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle button = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 16,
    fontWeight: _w700,
    color: AppColors.textOnPrimary,
  );

  static final TextStyle buttonSmall = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 13,
    fontWeight: _w700,
    color: AppColors.textOnPrimary,
  );

  static final TextStyle turn = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 18,
    fontWeight: _w700,
    color: AppColors.textOnPrimary,
  );

  static final TextStyle win = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 32,
    fontWeight: _w900,
    color: AppColors.white,
  );

  static final TextStyle statValue = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 26,
    fontWeight: _w900,
    color: AppColors.textPrimary,
  );

  static final TextStyle statTitle = TextStyle(
    fontFamily: AppConfig.fontInter,
    fontSize: 13,
    fontWeight: _w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get bangla => TextStyle(
        fontFamily: AppConfig.fontAnekBangla,
        fontWeight: _w500,
        color: AppColors.textPrimary,
      );
}