import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/features/settings/domain/app_settings.dart';

void main() {
  group('AppSettings unit formatting', () {
    test('AltitudeUnit formats SI meters per unit', () {
      expect(AltitudeUnit.feet.format(1000), '3281'); // 1000 * 3.28084
      expect(AltitudeUnit.meters.format(1000), '1000');
      expect(AltitudeUnit.feet.format(null), '—');
    });

    test('SpeedUnit formats SI m/s per unit', () {
      expect(SpeedUnit.kmh.format(100), '360');
      expect(SpeedUnit.knots.format(100), '194');
      expect(SpeedUnit.mph.format(100), '224');
      expect(SpeedUnit.kmh.format(null), '—');
    });
  });

  group('AppSettings.copyWith', () {
    test('overrides only the provided fields', () {
      const base = AppSettings.defaults;
      final next = base.copyWith(speedUnit: SpeedUnit.knots);

      expect(next.speedUnit, SpeedUnit.knots);
      expect(next.altitudeUnit, base.altitudeUnit);
      expect(next.refreshInterval, base.refreshInterval);
    });
  });
}
