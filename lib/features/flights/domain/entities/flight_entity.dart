import 'package:freezed_annotation/freezed_annotation.dart';

part 'flight_entity.freezed.dart';

/// A single aircraft's state, in the app's domain vocabulary. Pure Dart — no
/// Flutter or transport detail. Built from a [FlightStateDto] via `toEntity()`.
///
/// Altitudes and speed are kept in SI units (meters, m/s); the presentation
/// layer converts to feet / km-h via `UnitConverters`. Aircraft without a
/// known position are filtered out before reaching this type, so [latitude]
/// and [longitude] are non-null.
@freezed
sealed class FlightEntity with _$FlightEntity {
  const factory FlightEntity({
    required String icao24,
    required String originCountry,
    required double latitude,
    required double longitude,
    required bool onGround,
    String? callsign,
    double? baroAltitude,
    double? geoAltitude,
    double? velocity,
    double? trueTrack,
  }) = _FlightEntity;

  const FlightEntity._();

  /// Best available altitude in meters — geometric preferred, barometric
  /// as fallback.
  double? get altitude => geoAltitude ?? baroAltitude;

  /// Trimmed callsign, or null when blank.
  String? get displayCallsign {
    final c = callsign?.trim();
    return (c == null || c.isEmpty) ? null : c;
  }
}
