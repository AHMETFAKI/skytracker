import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import 'data_source.dart';

/// Centralized, read-only access to environment configuration. Reads the
/// `DATA_SOURCE` dart-define and secrets from the loaded `.env` so the rest of
/// the app never touches [dotenv] or [String.fromEnvironment] directly.
@singleton
class AppConfig {
  const AppConfig();

  /// Human-readable app version shown in the UI (mirrors `pubspec.yaml`).
  static const String appVersion = '1.0.0';

  /// Active flight data source, chosen at launch. Mirrors the precedence used
  /// in `bootstrap.dart` (dart-define > `.env` > mock) so the runtime view and
  /// the DI-wired repository always agree.
  DataSource get dataSource => DataSource.resolve(
        define: const String.fromEnvironment('DATA_SOURCE'),
        envValue: dotenv.maybeGet('DATA_SOURCE'),
      );

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

  /// Open style used when no MapTiler key is configured — keeps the map usable
  /// (graceful degrade) at the cost of the dark radar aesthetic.
  static const String _fallbackStyleUrl =
      'https://demotiles.maplibre.org/style.json';

  /// MapTiler dark style (radar look) when a key is present, otherwise the
  /// open demo style.
  String get mapStyleUrl => hasMapTilerKey
      ? 'https://api.maptiler.com/maps/streets-v2-dark/style.json?key=$mapTilerKey'
      : _fallbackStyleUrl;

  /// How often the map polls for fresh aircraft positions. Kept conservative to
  /// respect the OpenSky daily credit budget.
  Duration get refreshInterval {
    final raw = int.tryParse(dotenv.maybeGet('REFRESH_INTERVAL_SECONDS') ?? '');
    return Duration(seconds: (raw == null || raw < 10) ? 20 : raw);
  }

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
