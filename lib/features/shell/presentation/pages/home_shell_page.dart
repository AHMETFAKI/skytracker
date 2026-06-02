import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Two-tab shell (Map / Profile) backed by auto_route's nested tabs router.
@RoutePage()
class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Subscribe to the locale so the bottom-nav labels re-localize on a
    // language change (the shell is built once and would otherwise stay stale).
    final _ = context.locale;
    return AutoTabsScaffold(
      routes: const [FlightMapRoute(), ProfileRoute()],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            tabsRouter.setActiveIndex(index);
          },
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.18),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.radar_outlined),
              selectedIcon: const Icon(Icons.radar, color: AppColors.primary),
              label: 'shell.tab.map'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: 'shell.tab.profile'.tr(),
            ),
          ],
        );
      },
    );
  }
}
