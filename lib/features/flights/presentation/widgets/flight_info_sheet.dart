import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/unit_converters.dart';
import '../../domain/entities/flight_entity.dart';
import '../map/flight_palette.dart';

/// Bottom sheet describing a single tapped aircraft. Telemetry is converted
/// from SI to aviation units (ft / km-h / ft-min) and laid out as a compact
/// instrument cluster: altitude, ground speed, vertical trend, and a heading
/// compass.
class FlightInfoSheet extends StatelessWidget {
  const FlightInfoSheet({required this.flight, super.key});

  final FlightEntity flight;

  static Future<void> show(BuildContext context, FlightEntity flight) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FlightInfoSheet(flight: flight),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callsign = flight.displayCallsign ?? 'flight.unknownCallsign'.tr();
    final accent = FlightPalette.colorFor(
      altitudeMeters: flight.altitude,
      onGround: flight.onGround,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceVariant, AppColors.surface],
        ),
        border: const Border(top: BorderSide(color: AppColors.outline)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 18.h),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Icon(Icons.flight, color: accent, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(callsign, style: AppTextStyles.mono),
                      SizedBox(height: 2.h),
                      Text(
                        flight.originCountry,
                        style: AppTextStyles.bodyMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusChip(onGround: flight.onGround),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.height,
                    label: 'flight.altitude'.tr(),
                    value: UnitConverters.formatFeet(flight.altitude),
                    unit: 'units.ft'.tr(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _StatTile(
                    icon: Icons.speed,
                    label: 'flight.speed'.tr(),
                    value: UnitConverters.formatKmh(flight.velocity),
                    unit: 'units.kmh'.tr(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _VerticalTrendTile(flight: flight)),
                SizedBox(width: 12.w),
                Expanded(child: _HeadingTile(flight: flight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A single labelled telemetry readout.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.onSurfaceMuted),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                SizedBox(height: 2.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: AppTextStyles.mono.copyWith(
                          color: valueColor ?? AppColors.onSurface,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit != null) ...[
                      SizedBox(width: 4.w),
                      Text(unit!, style: AppTextStyles.labelSmall),
                    ],
                  ],
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Vertical-rate readout that switches icon/color with the climb/descend trend.
class _VerticalTrendTile extends StatelessWidget {
  const _VerticalTrendTile({required this.flight});

  final FlightEntity flight;

  @override
  Widget build(BuildContext context) {
    final (icon, color, labelKey) = switch (flight.verticalTrend) {
      VerticalTrend.climbing => (Icons.north, AppColors.success, 'flight.climbing'),
      VerticalTrend.descending => (Icons.south, AppColors.warning, 'flight.descending'),
      VerticalTrend.level => (Icons.trending_flat, AppColors.onSurfaceMuted, 'flight.level'),
    };

    return _StatTile(
      icon: icon,
      label: labelKey.tr(),
      value: UnitConverters.formatVerticalRate(flight.verticalRate),
      unit: 'units.fpm'.tr(),
      valueColor: color,
    );
  }
}

/// Heading readout with a compass arrow rotated to the aircraft's true track.
class _HeadingTile extends StatelessWidget {
  const _HeadingTile({required this.flight});

  final FlightEntity flight;

  @override
  Widget build(BuildContext context) {
    final track = flight.trueTrack;
    final value = track == null ? '—' : track.round().toString();

    return _StatTile(
      icon: Icons.explore_outlined,
      label: 'flight.heading'.tr(),
      value: value,
      unit: 'units.degree'.tr(),
      trailing: track == null
          ? null
          : Transform.rotate(
              angle: track * math.pi / 180.0,
              child: Icon(Icons.navigation, size: 18.sp, color: AppColors.primary),
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
    final label = onGround ? 'flight.onGround'.tr() : 'flight.airborne'.tr();

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
