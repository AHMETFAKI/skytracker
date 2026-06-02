import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/data_source.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/failure.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/repositories/flight_mock_repository.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/repositories/i_flight_repository.dart';

/// Immutable view the map screen renders.
class FlightsView {
  FlightsView({
    required this.flights,
    required this.source,
    required this.isMockFallback,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final List<FlightEntity> flights;

  /// Which source actually produced [flights] right now.
  final DataSource source;

  /// True when the remote source failed and we silently fell back to mock.
  final bool isMockFallback;

  /// Wall-clock time this snapshot was produced, used by the map HUD to show
  /// how stale the on-screen positions are.
  final DateTime updatedAt;
}

/// Loads aircraft states and refreshes them on a timer. Handles the
/// remote → mock fallback when OpenSky returns auth/rate-limit failures.
class FlightsController extends AsyncNotifier<FlightsView> {
  late final AppConfig _config;
  late final IFlightRepository _primary;

  Timer? _timer;
  bool _forceMock = false;

  @override
  Future<FlightsView> build() async {
    _config = getIt<AppConfig>();
    _primary = getIt<IFlightRepository>();

    // Poll on the user-selected interval; changing it re-runs build, which
    // cancels the old timer (via onDispose) and starts a fresh one.
    final interval = ref.watch(
      settingsControllerProvider.select((s) => s.refreshInterval),
    );
    _timer = Timer.periodic(interval, (_) => _tick());
    ref.onDispose(() => _timer?.cancel());

    return _load();
  }

  /// Manual refresh (pull-to-refresh / retry button).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  /// User-triggered switch to mock data after a remote failure.
  Future<void> switchToMock() async {
    _forceMock = true;
    await refresh();
  }

  Future<void> _tick() async {
    final next = await AsyncValue.guard(_load);
    // Don't clobber a visible error state with another error silently; only
    // publish successful refreshes or the first error.
    if (next.hasValue || !state.hasError) {
      state = next;
    }
  }

  Future<FlightsView> _load() async {
    if (_forceMock || _config.dataSource == DataSource.mock) {
      final flights = await _loadFromMock();
      return FlightsView(
        flights: flights,
        source: DataSource.mock,
        isMockFallback: _forceMock && _config.dataSource == DataSource.remote,
      );
    }

    final result = await _primary.getStates();
    return result.fold(
      (failure) async => _handleRemoteFailure(failure),
      (flights) async => FlightsView(
        flights: flights,
        source: DataSource.remote,
        isMockFallback: false,
      ),
    );
  }

  Future<FlightsView> _handleRemoteFailure(Failure failure) async {
    if (failure.isFallbackCandidate && _config.autoFallbackToMock) {
      final flights = await _loadFromMock();
      return FlightsView(
        flights: flights,
        source: DataSource.mock,
        isMockFallback: true,
      );
    }
    // Surface as an error so the UI can show retry / "switch to mock".
    throw failure;
  }

  Future<List<FlightEntity>> _loadFromMock() async {
    final mock = getIt<FlightMockRepository>();
    final result = await mock.getStates();
    return result.fold((failure) => throw failure, (flights) => flights);
  }
}

final flightsControllerProvider =
    AsyncNotifierProvider<FlightsController, FlightsView>(
  FlightsController.new,
);
