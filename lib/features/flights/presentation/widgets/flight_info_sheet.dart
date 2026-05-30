import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/unit_converters.dart';
import '../../domain/entities/flight_entity.dart';

/// Bottom sheet describing a single tapped aircraft. Altitude and speed are
/// converted from SI to aviation units (ft / km-h) for display.
class FlightInfoSheet extends StatelessWidget {
  const FlightInfoSheet({required this.flight, super.key});

  final FlightEntity flight;

  static Future<void> show(BuildContext context, FlightEntity flight) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FlightInfoSheet(flight: flight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callsign = flight.displayCallsign ?? 'flight.unknownCallsign'.tr();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.outline)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.flight, color: AppColors.primary, size: 22.sp),
              SizedBox(width: 10.w),
              Text(callsign, style: AppTextStyles.mono),
              const Spacer(),
              _StatusChip(onGround: flight.onGround),
            ],
          ),
          SizedBox(height: 16.h),
          _InfoRow(
            label: 'flight.country'.tr(),
            value: flight.originCountry,
          ),
          _InfoRow(
            label: 'flight.altitude'.tr(),
            value: '${UnitConverters.formatFeet(flight.altitude)} '
                '${'units.ft'.tr()}',
          ),
          _InfoRow(
            label: 'flight.speed'.tr(),
            value: '${UnitConverters.formatKmh(flight.velocity)} '
                '${'units.kmh'.tr()}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label, style: AppTextStyles.bodyMuted),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.onGround});

  final bool onGround;

  @override
  Widget build(BuildContext context) {
    final color = onGround ? AppColors.onSurfaceMuted : AppColors.success;
    final label =
        onGround ? 'flight.onGround'.tr() : 'flight.airborne'.tr();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
