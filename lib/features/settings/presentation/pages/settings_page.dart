import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/app_settings.dart';
import '../providers/settings_provider.dart';

/// Preferences screen (units + refresh cadence), reached from the Profile tab.
/// Changes persist immediately and propagate to the flight map and info sheet.
@RoutePage()
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _SettingCard(
              icon: Icons.height,
              title: 'settings.altitudeUnit'.tr(),
              child: _ChoiceRow<AltitudeUnit>(
                value: settings.altitudeUnit,
                options: AltitudeUnit.values,
                labelOf: (u) => u.labelKey.tr(),
                onChanged: controller.setAltitudeUnit,
              ),
            ),
            SizedBox(height: 12.h),
            _SettingCard(
              icon: Icons.speed,
              title: 'settings.speedUnit'.tr(),
              child: _ChoiceRow<SpeedUnit>(
                value: settings.speedUnit,
                options: SpeedUnit.values,
                labelOf: (u) => u.labelKey.tr(),
                onChanged: controller.setSpeedUnit,
              ),
            ),
            SizedBox(height: 12.h),
            _SettingCard(
              icon: Icons.timelapse,
              title: 'settings.refreshInterval'.tr(),
              child: _ChoiceRow<Duration>(
                value: settings.refreshInterval,
                options: AppSettings.refreshOptions,
                labelOf: (d) =>
                    'settings.refreshSeconds'.tr(args: ['${d.inSeconds}']),
                onChanged: controller.setRefreshInterval,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'settings.note'.tr(),
                style: AppTextStyles.bodyMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(title, style: AppTextStyles.titleMedium),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

/// A wrapping set of single-select chips. Generic so it serves enums and
/// durations alike.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(labelOf(option)),
            selected: option == value,
            showCheckmark: false,
            labelStyle: AppTextStyles.labelSmall.copyWith(
              color: option == value
                  ? AppColors.onPrimary
                  : AppColors.onSurface,
            ),
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: option == value ? AppColors.primary : AppColors.outline,
            ),
            onSelected: (selected) {
              if (!selected) return;
              HapticFeedback.selectionClick();
              onChanged(option);
            },
          ),
      ],
    );
  }
}
