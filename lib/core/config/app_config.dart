import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import 'data_source.dart';

/// Centralized, read-only access to environment configuration. Reads the
/// `DATA_SOURCE` dart-define and secrets from the loaded `.env` so the rest of
/// the app never touches [dotenv] or [String.fromEnvironment] directly.
@singleton
class AppConfig {
  const AppConfig();

  static const String _dataSourceDefine =
      String.fromEnvironment('DATA_SOURCE', defaultValue: 'mock');

  /// Active flight data source, chosen at launch.
  DataSource get dataSource => DataSource.fromString(_dataSourceDefine);

  /// When true, a remote auth/rate-limit failure auto-falls back to mock data
  /// instead of only surfacing a "switch to mock" action.
  bool get autoFallbackToMock =>
      _envBool('AUTO_FALLBACK_TO_MOCK', defaultValue: true);

  String get openSkyClientId => _env('OPENSKY_CLIENT_ID');
  String get openSkyClientSecret => _env('OPENSKY_CLIENT_SECRET');
  String get mapTilerKey => _env('MAPTILER_KEY');

  bool get hasOpenSkyCredentials =>
      openSkyClientId.isNotEmpty && openSkyClientSecret.isNotEmpty;
  bool get hasMapTilerKey => mapTilerKey.isNotEmpty;

  String _env(String key) => dotenv.maybeGet(key) ?? '';

  bool _envBool(String key, {required bool defaultValue}) {
    final raw = dotenv.maybeGet(key)?.trim().toLowerCase();
    return switch (raw) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => defaultValue,
    };
  }
}
