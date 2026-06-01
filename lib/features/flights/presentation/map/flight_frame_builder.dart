import 'dart:math' as math;

import 'package:flutter/animation.dart';

import '../../domain/entities/flight_entity.dart';
import 'flight_geojson.dart';
import 'flight_palette.dart';

/// A point sampled along an aircraft's animated track.
class FlightSample {
  const FlightSample({
    required this.longitude,
    required this.latitude,
    required this.bearing,
  });

  final double longitude;
  final double latitude;
  final double bearing;
}

/// Drives smooth aircraft motion between discrete data refreshes.
///
/// OpenSky (and the mock) report positions every [FlightsController] tick; a raw
/// re-render would teleport each plane to its new spot. This builder remembers
/// the last on-screen position of every aircraft and, given an interpolation
/// fraction `t` advancing 0→1 over the refresh interval, emits intermediate
/// GeoJSON so planes glide.
///
/// At high traffic counts per-frame serialization gets expensive, so above
/// [maxInterpolated] aircraft interpolation is disabled (positions snap on each
/// refresh) — clustering keeps the map readable at that density anyway.
class FlightFrameBuilder {
  FlightFrameBuilder({this.maxInterpolated = 600});

  final int maxInterpolated;
  final Map<String, _Track> _tracks = {};
  bool _animate = true;

  /// Whether the most recent target set is being interpolated (vs. snapped).
  bool get animate => _animate;

  /// Records a fresh set of target positions, sampled from [flights]. The
  /// aircraft's current on-screen position (at [currentT] of the previous leg)
  /// becomes the start of the new leg, so motion stays continuous even when an
  /// update lands mid-animation.
  void setTargets(List<FlightEntity> flights, double currentT) {
    _animate = flights.length <= maxInterpolated;
    final seen = <String>{};

    for (final f in flights) {
      seen.add(f.icao24);
      final color = FlightPalette.hexFor(
        altitudeMeters: f.altitude,
        onGround: f.onGround,
      );
      final bearing = f.trueTrack;
      final existing = _tracks[f.icao24];

      if (existing == null) {
        _tracks[f.icao24] = _Track(
          fromLng: f.longitude,
          fromLat: f.latitude,
          fromBearing: bearing ?? 0,
          toLng: f.longitude,
          toLat: f.latitude,
          toBearing: bearing ?? 0,
          callsign: f.displayCallsign ?? '',
          color: color,
          onGround: f.onGround,
        );
      } else {
        final current = existing.sampleAt(_ease(currentT));
        _tracks[f.icao24] = _Track(
          fromLng: current.longitude,
          fromLat: current.latitude,
          fromBearing: current.bearing,
          toLng: f.longitude,
          toLat: f.latitude,
          toBearing: bearing ?? current.bearing,
          callsign: f.displayCallsign ?? '',
          color: color,
          onGround: f.onGround,
        );
      }
    }

    _tracks.removeWhere((key, _) => !seen.contains(key));
  }

  /// True once at least one target set has been recorded.
  bool get isEmpty => _tracks.isEmpty;

  /// Builds the full symbol-layer feature collection at fraction [t].
  Map<String, dynamic> buildFrame(double t) {
    final eased = _ease(t);
    return {
      'type': 'FeatureCollection',
      'features': [
        for (final entry in _tracks.entries)
          _featureFor(entry.key, entry.value, eased),
      ],
    };
  }

  /// Current sample for a single aircraft, or null if it is no longer tracked.
  FlightSample? sampleOf(String icao24, double t) =>
      _tracks[icao24]?.sampleAt(_ease(t));

  double _ease(double t) =>
      _animate ? Curves.easeInOut.transform(t.clamp(0.0, 1.0)) : 1.0;

  Map<String, dynamic> _featureFor(String icao24, _Track track, double eased) {
    final sample = track.sampleAt(eased);
    return buildFlightFeature(
      icao24: icao24,
      callsign: track.callsign,
      longitude: sample.longitude,
      latitude: sample.latitude,
      bearing: sample.bearing,
      onGround: track.onGround,
      color: track.color,
    );
  }
}

/// Builds a short LineString ahead of [sample] along its heading, used to draw
/// the projected-track line for the selected aircraft. Returns an empty
/// collection when [sample] is null.
Map<String, dynamic> headingLineCollection(FlightSample? sample) {
  if (sample == null) return emptyFeatureCollection();

  const degrees = 0.6; // ~track length in degrees of latitude
  final rad = sample.bearing * math.pi / 180.0;
  final cosLat = math.cos(sample.latitude * math.pi / 180.0).abs();
  final endLat = sample.latitude + degrees * math.cos(rad);
  final endLng = sample.longitude +
      (cosLat < 1e-6 ? 0 : degrees * math.sin(rad) / cosLat);

  return {
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [sample.longitude, sample.latitude],
            [endLng, endLat],
          ],
        },
        'properties': const <String, dynamic>{},
      },
    ],
  };
}

/// A single-point collection at [sample], used for the selection highlight ring.
Map<String, dynamic> selectedPointCollection(FlightSample? sample) {
  if (sample == null) return emptyFeatureCollection();
  return {
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [sample.longitude, sample.latitude],
        },
        'properties': const <String, dynamic>{},
      },
    ],
  };
}

class _Track {
  _Track({
    required this.fromLng,
    required this.fromLat,
    required this.fromBearing,
    required this.toLng,
    required this.toLat,
    required this.toBearing,
    required this.callsign,
    required this.color,
    required this.onGround,
  });

  final double fromLng;
  final double fromLat;
  final double fromBearing;
  final double toLng;
  final double toLat;
  final double toBearing;
  final String callsign;
  final String color;
  final bool onGround;

  FlightSample sampleAt(double t) {
    return FlightSample(
      longitude: fromLng + (toLng - fromLng) * t,
      latitude: fromLat + (toLat - fromLat) * t,
      bearing: _lerpAngle(fromBearing, toBearing, t),
    );
  }

  /// Interpolates an angle along the shortest arc, so a plane crossing 359°→1°
  /// turns 2° rather than spinning 358° the other way.
  static double _lerpAngle(double a, double b, double t) {
    var diff = (b - a) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    final result = (a + diff * t) % 360;
    return result < 0 ? result + 360 : result;
  }
}
