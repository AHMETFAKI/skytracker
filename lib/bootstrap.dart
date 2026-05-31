import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'core/config/data_source.dart';
import 'core/di/injection.dart';
import 'core/firebase/firebase_init.dart';
import 'features/auth/data/auth_session.dart';

/// App entrypoint shared by every flavor.
///
/// Reads the `DATA_SOURCE` flag which selects the injectable environment that
/// decides whether the real OpenSky or the local mock repository is wired up.
/// Precedence: `--dart-define=DATA_SOURCE=mock|remote` wins, then the `.env`
/// value, otherwise `mock` (see [DataSource.resolve]).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(isOptional: true);
  await initializeFirebase();

  const dataSourceDefine = String.fromEnvironment('DATA_SOURCE');
  final dataSource = DataSource.resolve(
    define: dataSourceDefine,
    envValue: dotenv.maybeGet('DATA_SOURCE'),
  );
  await configureDependencies(dataSource);
  await enforceRememberMeOnStartup();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: const ProviderScope(child: SkyTrackerApp()),
    ),
  );
}
