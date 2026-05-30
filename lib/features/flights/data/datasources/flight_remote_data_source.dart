import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/bounding_box.dart';
import '../dtos/flight_state_dto.dart';

/// Fetches live aircraft states from the OpenSky `/states/all` endpoint. The
/// injected [Dio] is OAuth-authenticated (see [OpenSkyDioModule]); this class
/// only shapes the request and parses the positional response.
@lazySingleton
@Environment('remote')
class FlightRemoteDataSource {
  const FlightRemoteDataSource(@Named('opensky') this._dio);

  final Dio _dio;

  Future<List<FlightStateDto>> getStates({BoundingBox? bbox}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/states/all',
      queryParameters: bbox == null
          ? null
          : {
              'lamin': bbox.lamin,
              'lomin': bbox.lomin,
              'lamax': bbox.lamax,
              'lomax': bbox.lomax,
            },
    );

    final body = response.data;
    if (body == null) {
      throw const ServerException('Empty OpenSky response');
    }

    final states = body['states'] as List<dynamic>? ?? const [];
    return states
        .cast<List<dynamic>>()
        .map(FlightStateDto.fromStateVector)
        .toList(growable: false);
  }
}
