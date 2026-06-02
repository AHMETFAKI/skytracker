import '../../../core/utils/unit_converters.dart';

/// Altitude display unit.
enum AltitudeUnit {
  feet('units.ft'),
  meters('units.m');

  const AltitudeUnit(this.labelKey);

  /// easy_localization key for the short unit label.
  final String labelKey;

  /// Formats an SI altitude (meters) into this unit's rounded integer string.
  String format(double? meters) => switch (this) {
        AltitudeUnit.feet => UnitConverters.formatFeet(meters),
        AltitudeUnit.meters => UnitConverters.formatMeters(meters),
      };
}

/// Ground-speed display unit.
enum SpeedUnit {
  kmh('units.kmh'),
  knots('units.kn'),
  mph('units.mph');

  const SpeedUnit(this.labelKey);

  final String labelKey;

  /// Formats an SI speed (m/s) into this unit's rounded integer string.
  String format(double? mps) => switch (this) {
        SpeedUnit.kmh => UnitConverters.formatKmh(mps),
        SpeedUnit.knots => UnitConverters.formatKnots(mps),
        SpeedUnit.mph => UnitConverters.formatMph(mps),
      };
}

/// User-tunable preferences, persisted across launches. Pure value object.
class AppSettings {
  const AppSettings({
    required this.altitudeUnit,
    required this.speedUnit,
    required this.refreshInterval,
  });

  final AltitudeUnit altitudeUnit;
  final SpeedUnit speedUnit;
  final Duration refreshInterval;

  /// Selectable polling intervals offered in the settings UI.
  static const List<Duration> refreshOptions = [
    Duration(seconds: 10),
    Duration(seconds: 20),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ];

  static const AppSettings defaults = AppSettings(
    altitudeUnit: AltitudeUnit.feet,
    speedUnit: SpeedUnit.kmh,
    refreshInterval: Duration(seconds: 20),
  );

  AppSettings copyWith({
    AltitudeUnit? altitudeUnit,
    SpeedUnit? speedUnit,
    Duration? refreshInterval,
  }) {
    return AppSettings(
      altitudeUnit: altitudeUnit ?? this.altitudeUnit,
      speedUnit: speedUnit ?? this.speedUnit,
      refreshInterval: refreshInterval ?? this.refreshInterval,
    );
  }
}
