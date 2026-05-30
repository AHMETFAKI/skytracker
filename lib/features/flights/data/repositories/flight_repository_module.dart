import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_flight_repository.dart';
import 'flight_mock_repository.dart';
import 'flight_remote_repository.dart';

/// Binds [IFlightRepository] to the implementation selected by the active
/// `DATA_SOURCE` environment. The concrete [FlightMockRepository] remains
/// resolvable in both environments so the remote flow can fall back to mock.
@module
abstract class FlightRepositoryModule {
  @Environment('mock')
  @lazySingleton
  IFlightRepository mock(FlightMockRepository repository) => repository;

  @Environment('remote')
  @lazySingleton
  IFlightRepository remote(FlightRemoteRepository repository) => repository;
}
