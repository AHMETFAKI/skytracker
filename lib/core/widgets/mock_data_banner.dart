import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Slim banner shown while the app is serving mock flight data, so the demo
/// state is never mistaken for live traffic.
class MockDataBanner extends StatelessWidget {
  const MockDataBanner({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      color: AppColors.warning.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 14.sp, color: AppColors.warning),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
          ),
        ],
      ),
    );
  }
}
