/// Pure unit conversions for flight telemetry. OpenSky reports SI units
/// (meters, m/s); the UI shows aviation-friendly feet and km/h.
abstract final class UnitConverters {
  const UnitConverters._();

  static const double _metersToFeet = 3.28084;
  static const double _mpsToKmh = 3.6;
  static const double _mpsToKnots = 1.94384;

  /// Meters → feet (altitude readout).
  static double metersToFeet(double meters) => meters * _metersToFeet;

  /// Meters/second → kilometers/hour (ground speed readout).
  static double mpsToKmh(double mps) => mps * _mpsToKmh;

  /// Meters/second → knots (optional aviation speed unit).
  static double mpsToKnots(double mps) => mps * _mpsToKnots;

  /// Rounded feet as an integer string, e.g. `35000`.
  static String formatFeet(double? meters) {
    if (meters == null) return '—';
    return metersToFeet(meters).round().toString();
  }

  /// Rounded km/h as an integer string, e.g. `842`.
  static String formatKmh(double? mps) {
    if (mps == null) return '—';
    return mpsToKmh(mps).round().toString();
  }
}
