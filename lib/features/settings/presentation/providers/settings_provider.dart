import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/settings_store.dart';
import '../../domain/app_settings.dart';

/// Holds the active [AppSettings], seeded synchronously from the persisted
/// store so dependents (the flight poller, the info sheet) can read it without
/// an async gate. Mutations persist and update state in place.
class SettingsController extends Notifier<AppSettings> {
  late final SettingsStore _store;

  @override
  AppSettings build() {
    _store = getIt<SettingsStore>();
    return _store.read();
  }

  void setAltitudeUnit(AltitudeUnit unit) =>
      _update(state.copyWith(altitudeUnit: unit));

  void setSpeedUnit(SpeedUnit unit) =>
      _update(state.copyWith(speedUnit: unit));

  void setRefreshInterval(Duration interval) =>
      _update(state.copyWith(refreshInterval: interval));

  void _update(AppSettings next) {
    state = next;
    _store.write(next);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
