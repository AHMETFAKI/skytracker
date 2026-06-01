import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Maps a flight's altitude (and ground state) to a marker color, so the map
/// reads like an aviation chart at a glance: low/green → cruise/turquoise →
/// high/violet, with grounded traffic dimmed out.
///
/// Lives in the presentation layer because it is purely a styling concern; the
/// domain keeps altitudes in SI meters.
abstract final class FlightPalette {
  const FlightPalette._();

  /// Altitude stops in meters paired with their color. Interpolated linearly.
  static const List<(double, Color)> _ramp = [
    (0, Color(0xFF34D399)), // sea level — green
    (3000, Color(0xFF38BDF8)), // low cruise — sky blue
    (7000, Color(0xFF22D3EE)), // cruise — turquoise (brand primary)
    (11000, Color(0xFF7C5CFF)), // high cruise — violet
    (13000, Color(0xFFC084FC)), // very high — light violet
  ];

  /// Color shown for aircraft reported on the ground.
  static const Color ground = AppColors.onSurfaceMuted;

  /// Resolves the marker color for an aircraft.
  static Color colorFor({required double? altitudeMeters, required bool onGround}) {
    if (onGround) return ground;
    final alt = altitudeMeters;
    if (alt == null) return _ramp.first.$2;

    if (alt <= _ramp.first.$1) return _ramp.first.$2;
    if (alt >= _ramp.last.$1) return _ramp.last.$2;

    for (var i = 0; i < _ramp.length - 1; i++) {
      final (lo, loColor) = _ramp[i];
      final (hi, hiColor) = _ramp[i + 1];
      if (alt >= lo && alt <= hi) {
        final t = (alt - lo) / (hi - lo);
        return Color.lerp(loColor, hiColor, t)!;
      }
    }
    return _ramp.last.$2;
  }

  /// `#RRGGBB` string for use as a GeoJSON feature property consumed by a
  /// MapLibre `iconColor` expression.
  static String hexFor({required double? altitudeMeters, required bool onGround}) {
    return toHex(colorFor(altitudeMeters: altitudeMeters, onGround: onGround));
  }

  /// Converts a [Color] to a `#RRGGBB` hex string (alpha dropped).
  static String toHex(Color color) {
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Discrete legend entries (label key, color) shown in the map HUD.
  static const List<(String, Color)> legend = [
    ('map.legend.ground', ground),
    ('map.legend.low', Color(0xFF34D399)),
    ('map.legend.cruise', Color(0xFF22D3EE)),
    ('map.legend.high', Color(0xFF7C5CFF)),
  ];
}
