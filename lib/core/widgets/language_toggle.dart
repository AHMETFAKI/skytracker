import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Compact TR/EN switch. Reads and updates the active locale via
/// easy_localization so the whole app re-localizes at runtime.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  static const _locales = [Locale('tr'), Locale('en')];

  @override
  Widget build(BuildContext context) {
    final current = context.locale;
    return SegmentedButton<Locale>(
      segments: _locales
          .map(
            (locale) => ButtonSegment<Locale>(
              value: locale,
              label: Text(locale.languageCode.toUpperCase()),
            ),
          )
          .toList(),
      selected: {_locales.firstWhere((l) => l.languageCode == current.languageCode, orElse: () => _locales.last)},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => context.setLocale(selection.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.onSurfaceMuted,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
      ),
    );
  }
}
