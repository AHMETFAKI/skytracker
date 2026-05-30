import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../dtos/flight_state_dto.dart';

/// Serves flight state vectors from a bundled JSON asset whose schema matches
/// the live OpenSky `/states/all` response. Lets the whole app run and demo
/// without any API key or network.
@lazySingleton
class FlightMockDataSource {
  const FlightMockDataSource();

  static const String _assetPath = 'assets/mock/flights_mock.json';

  Future<List<FlightStateDto>> getStates() async {
    try {
      // Small delay so loading states are exercised like a real request.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final states = decoded['states'] as List<dynamic>? ?? const [];

      return states
          .cast<List<dynamic>>()
          .map(FlightStateDto.fromStateVector)
          .toList(growable: false);
    } on Object catch (e) {
      throw CacheException('Failed to load mock flights: $e');
    }
  }
}
