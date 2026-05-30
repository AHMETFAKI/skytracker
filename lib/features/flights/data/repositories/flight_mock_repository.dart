import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/repositories/i_flight_repository.dart';
import '../datasources/flight_mock_data_source.dart';

/// Mock-backed [IFlightRepository]. Bound to `IFlightRepository` in the `mock`
/// environment, and always registered as a concrete type so the remote flow
/// can fall back to it at runtime.
@lazySingleton
class FlightMockRepository implements IFlightRepository {
  const FlightMockRepository(this._dataSource);

  final FlightMockDataSource _dataSource;

  @override
  Future<Either<Failure, List<FlightEntity>>> getStates({
    BoundingBox? bbox,
  }) async {
    try {
      final dtos = await _dataSource.getStates();
      final flights = dtos
          .map((dto) => dto.toEntity())
          .whereType<FlightEntity>()
          .toList(growable: false);
      return Right(flights);
    } on Object catch (e) {
      return Left(FailureMapper.map(e));
    }
  }
}
