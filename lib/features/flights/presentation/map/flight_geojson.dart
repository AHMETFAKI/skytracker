import '../../domain/entities/flight_entity.dart';
import 'flight_palette.dart';

/// Converts flight entities into a GeoJSON `FeatureCollection` for the MapLibre
/// symbol layer. `icao24` is the feature id so taps resolve straight back to an
/// aircraft; `bearing` drives icon rotation and `color` drives the per-altitude
/// `iconColor` expression.
Map<String, dynamic> flightsToGeoJson(List<FlightEntity> flights) {
  return {
    'type': 'FeatureCollection',
    'features': [
      for (final f in flights)
        buildFlightFeature(
          icao24: f.icao24,
          callsign: f.displayCallsign ?? '',
          longitude: f.longitude,
          latitude: f.latitude,
          bearing: f.trueTrack ?? 0.0,
          onGround: f.onGround,
          color: FlightPalette.hexFor(
            altitudeMeters: f.altitude,
            onGround: f.onGround,
          ),
        ),
    ],
  };
}

/// Builds a single GeoJSON point feature for an aircraft. Shared by the static
/// path and the per-frame interpolated path so both produce identical schemas.
Map<String, dynamic> buildFlightFeature({
  required String icao24,
  required String callsign,
  required double longitude,
  required double latitude,
  required double bearing,
  required bool onGround,
  required String color,
}) {
  return {
    'type': 'Feature',
    'id': icao24,
    'geometry': {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    },
    'properties': {
      'icao24': icao24,
      'callsign': callsign,
      'bearing': bearing,
      'color': color,
      'onGround': onGround,
    },
  };
}

/// An empty collection, used to initialize or clear a source.
Map<String, dynamic> emptyFeatureCollection() => {
      'type': 'FeatureCollection',
      'features': const <dynamic>[],
    };
