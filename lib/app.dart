import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Root widget. The radar/cockpit [ThemeData] and the `auto_route` router are
/// wired up in Phase 2; for now a minimal placeholder validates that
/// localization + responsive scaling are correctly initialized.
class SkyTrackerApp extends ConsumerWidget {
  const SkyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
        title: 'SkyTracker',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData.dark(useMaterial3: true),
        home: const _BootstrapPlaceholder(),
      ),
    );
  }
}

class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_takeoff, size: 64.r),
            SizedBox(height: 16.h),
            Text('app.name'.tr(),
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 8.h),
            Text('app.tagline'.tr(),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
