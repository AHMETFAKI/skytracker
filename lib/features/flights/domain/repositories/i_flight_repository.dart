import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/bounding_box.dart';
import '../entities/flight_entity.dart';

/// Domain contract for retrieving live aircraft states. Two implementations
/// satisfy it — remote (OpenSky) and mock — selected at startup via the
/// `DATA_SOURCE` switch. Presentation depends only on this interface.
abstract interface class IFlightRepository {
  /// Returns the current set of airborne/grounded aircraft. An optional
  /// [bbox] limits results to a geographic window (saves API credits).
  Future<Either<Failure, List<FlightEntity>>> getStates({BoundingBox? bbox});
}
