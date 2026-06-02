/// Pure unit conversions for flight telemetry. OpenSky reports SI units
/// (meters, m/s); the UI shows aviation-friendly feet and km/h.
abstract final class UnitConverters {
  const UnitConverters._();

  static const double _metersToFeet = 3.28084;
  static const double _mpsToKmh = 3.6;
  static const double _mpsToKnots = 1.94384;
  static const double _mpsToMph = 2.23694;
  static const double _mpsToFeetPerMin = 196.8504; // 3.28084 * 60

  /// Meters → feet (altitude readout).
  static double metersToFeet(double meters) => meters * _metersToFeet;

  /// Meters/second → kilometers/hour (ground speed readout).
  static double mpsToKmh(double mps) => mps * _mpsToKmh;

  /// Meters/second → knots (optional aviation speed unit).
  static double mpsToKnots(double mps) => mps * _mpsToKnots;

  /// Meters/second → miles/hour.
  static double mpsToMph(double mps) => mps * _mpsToMph;

  /// Rounded feet as an integer string, e.g. `35000`.
  static String formatFeet(double? meters) {
    if (meters == null) return '—';
    return metersToFeet(meters).round().toString();
  }

  /// Rounded meters as an integer string, e.g. `10668`.
  static String formatMeters(double? meters) {
    if (meters == null) return '—';
    return meters.round().toString();
  }

  /// Rounded km/h as an integer string, e.g. `842`.
  static String formatKmh(double? mps) {
    if (mps == null) return '—';
    return mpsToKmh(mps).round().toString();
  }

  /// Rounded knots as an integer string.
  static String formatKnots(double? mps) {
    if (mps == null) return '—';
    return mpsToKnots(mps).round().toString();
  }

  /// Rounded mph as an integer string.
  static String formatMph(double? mps) {
    if (mps == null) return '—';
    return mpsToMph(mps).round().toString();
  }

  /// Vertical speed in feet/minute, signed and rounded to the nearest 50,
  /// e.g. `+1200`, `-800`, `0`.
  static String formatVerticalRate(double? mps) {
    if (mps == null) return '—';
    final fpm = (mps * _mpsToFeetPerMin / 50).round() * 50;
    if (fpm == 0) return '0';
    return fpm > 0 ? '+$fpm' : '$fpm';
  }
}
