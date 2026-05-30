/// Geographic query window for the OpenSky `/states/all` endpoint. Passing a
/// bbox narrows results to the visible map area and saves API credits.
class BoundingBox {
  const BoundingBox({
    required this.lamin,
    required this.lomin,
    required this.lamax,
    required this.lomax,
  });

  /// Minimum latitude (south edge).
  final double lamin;

  /// Minimum longitude (west edge).
  final double lomin;

  /// Maximum latitude (north edge).
  final double lamax;

  /// Maximum longitude (east edge).
  final double lomax;
}
