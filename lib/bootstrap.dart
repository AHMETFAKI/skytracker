import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';

/// App entrypoint shared by every flavor.
///
/// Reads the `DATA_SOURCE` flag (`--dart-define=DATA_SOURCE=mock|remote`,
/// default `mock`) which, from Phase 3 onwards, selects the injectable
/// environment that decides whether the real OpenSky or the local mock
/// repository is wired up.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(isOptional: true);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: const ProviderScope(child: SkyTrackerApp()),
    ),
  );
}
