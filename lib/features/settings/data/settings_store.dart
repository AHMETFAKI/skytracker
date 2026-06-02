import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// Persists [AppSettings] in [SharedPreferences]. Reads are synchronous so the
/// settings provider can seed itself without an async gate; writes are
/// fire-and-forget persistence.
@lazySingleton
class SettingsStore {
  SettingsStore(this._prefs);

  static const _altitudeKey = 'settings.altitude_unit';
  static const _speedKey = 'settings.speed_unit';
  static const _refreshKey = 'settings.refresh_seconds';

  final SharedPreferences _prefs;

  AppSettings read() {
    return AppSettings(
      altitudeUnit: _enumByName(
        AltitudeUnit.values,
        _prefs.getString(_altitudeKey),
        AppSettings.defaults.altitudeUnit,
      ),
      speedUnit: _enumByName(
        SpeedUnit.values,
        _prefs.getString(_speedKey),
        AppSettings.defaults.speedUnit,
      ),
      refreshInterval: Duration(
        seconds: _prefs.getInt(_refreshKey) ??
            AppSettings.defaults.refreshInterval.inSeconds,
      ),
    );
  }

  Future<void> write(AppSettings settings) async {
    await _prefs.setString(_altitudeKey, settings.altitudeUnit.name);
    await _prefs.setString(_speedKey, settings.speedUnit.name);
    await _prefs.setInt(_refreshKey, settings.refreshInterval.inSeconds);
  }

  static T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
