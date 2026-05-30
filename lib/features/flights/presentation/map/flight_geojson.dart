import '../../domain/entities/flight_entity.dart';

/// Converts flight entities into a GeoJSON `FeatureCollection` for the MapLibre
/// symbol layer. `icao24` is set as the feature id (via `promoteId`) so taps
/// resolve straight back to an aircraft; `bearing` drives icon rotation.
Map<String, dynamic> flightsToGeoJson(List<FlightEntity> flights) {
  return {
    'type': 'FeatureCollection',
    'features': [
      for (final f in flights)
        {
          'type': 'Feature',
          'id': f.icao24,
          'geometry': {
            'type': 'Point',
            'coordinates': [f.longitude, f.latitude],
          },
          'properties': {
            'icao24': f.icao24,
            'callsign': f.displayCallsign ?? '',
            'bearing': f.trueTrack ?? 0.0,
          },
        },
    ],
  };
}
