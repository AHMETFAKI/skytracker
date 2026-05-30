import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Wires the radar/cockpit [AppTheme], the `auto_route` router
/// (resolved from DI), responsive scaling and localization.
class SkyTrackerApp extends ConsumerWidget {
  const SkyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = getIt<AppRouter>();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp.router(
        title: 'SkyTracker',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.dark,
        routerConfig: router.config(),
      ),
    );
  }
}
