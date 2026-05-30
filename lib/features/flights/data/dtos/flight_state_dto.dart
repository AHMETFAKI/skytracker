import '../../domain/entities/flight_entity.dart';

/// Maps a single OpenSky *state vector* — a positional JSON array, not an
/// object — into a typed DTO, then into a [FlightEntity].
///
/// The same schema is used by both the live `/states/all` response and the
/// bundled mock JSON, so switching data sources never changes parsing.
/// Field indices follow the OpenSky API (see `docs/06-api-opensky.md`).
class FlightStateDto {
  const FlightStateDto({
    required this.icao24,
    required this.originCountry,
    required this.onGround,
    this.callsign,
    this.longitude,
    this.latitude,
    this.baroAltitude,
    this.velocity,
    this.trueTrack,
    this.geoAltitude,
  });

  final String icao24;
  final String? callsign;
  final String originCountry;
  final double? longitude;
  final double? latitude;
  final double? baroAltitude;
  final bool onGround;
  final double? velocity;
  final double? trueTrack;
  final double? geoAltitude;

  /// Parses one positional state vector. Out-of-range or wrongly-typed cells
  /// degrade to null rather than throwing, so a single odd row can't break the
  /// whole response.
  factory FlightStateDto.fromStateVector(List<dynamic> v) {
    String at0() => (v.isNotEmpty ? v[0] : '') as String? ?? '';

    return FlightStateDto(
      icao24: at0(),
      callsign: _string(v, 1),
      originCountry: _string(v, 2) ?? '',
      longitude: _double(v, 5),
      latitude: _double(v, 6),
      baroAltitude: _double(v, 7),
      onGround: _bool(v, 8),
      velocity: _double(v, 9),
      trueTrack: _double(v, 10),
      geoAltitude: _double(v, 13),
    );
  }

  /// Converts to a domain entity, or null when the aircraft has no position
  /// (cannot be placed on the map).
  FlightEntity? toEntity() {
    final lat = latitude;
    final lon = longitude;
    if (lat == null || lon == null) return null;

    return FlightEntity(
      icao24: icao24,
      originCountry: originCountry,
      latitude: lat,
      longitude: lon,
      onGround: onGround,
      callsign: callsign,
      baroAltitude: baroAltitude,
      geoAltitude: geoAltitude,
      velocity: velocity,
      trueTrack: trueTrack,
    );
  }

  static String? _string(List<dynamic> v, int i) {
    if (i >= v.length) return null;
    final raw = v[i];
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _double(List<dynamic> v, int i) {
    if (i >= v.length) return null;
    final raw = v[i];
    return switch (raw) {
      final num n => n.toDouble(),
      _ => null,
    };
  }

  static bool _bool(List<dynamic> v, int i) {
    if (i >= v.length) return false;
    return v[i] == true;
  }
}
