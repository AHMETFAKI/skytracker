import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Screen-aware text styles. Sizes use `.sp` so typography scales with
/// [flutter_screenutil].
abstract final class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get displayLarge => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: 0.2,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMuted => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceMuted,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceMuted,
        letterSpacing: 0.4,
      );

  /// Monospace-flavored style for technical readouts (callsign, altitude...).
  static TextStyle get mono => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 1.2,
      );
}
