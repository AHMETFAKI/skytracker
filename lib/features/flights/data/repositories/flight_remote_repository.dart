import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/bounding_box.dart';
import '../../domain/entities/flight_entity.dart';
import '../../domain/repositories/i_flight_repository.dart';
import '../datasources/flight_remote_data_source.dart';

/// OpenSky-backed [IFlightRepository]. Bound to `IFlightRepository` in the
/// `remote` environment. Auth/rate-limit failures surface as
/// [AuthFailure]/[RateLimitFailure] so the presentation layer can offer a mock
/// fallback.
@lazySingleton
@Environment('remote')
class FlightRemoteRepository implements IFlightRepository {
  const FlightRemoteRepository(this._dataSource);

  final FlightRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<FlightEntity>>> getStates({
    BoundingBox? bbox,
  }) async {
    try {
      final dtos = await _dataSource.getStates(bbox: bbox);
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
