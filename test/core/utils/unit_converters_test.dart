import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/core/utils/unit_converters.dart';

void main() {
  group('UnitConverters', () {
    test('metersToFeet converts using the standard factor', () {
      expect(UnitConverters.metersToFeet(1000), closeTo(3280.84, 0.01));
      expect(UnitConverters.metersToFeet(0), 0);
    });

    test('mpsToKmh converts m/s to km/h', () {
      expect(UnitConverters.mpsToKmh(100), closeTo(360, 0.001));
      expect(UnitConverters.mpsToKmh(0), 0);
    });

    test('mpsToKnots converts m/s to knots', () {
      expect(UnitConverters.mpsToKnots(10), closeTo(19.4384, 0.001));
    });

    test('formatFeet rounds and renders null as a dash', () {
      expect(UnitConverters.formatFeet(10000), '32808');
      expect(UnitConverters.formatFeet(null), '—');
    });

    test('formatKmh rounds and renders null as a dash', () {
      expect(UnitConverters.formatKmh(250), '900');
      expect(UnitConverters.formatKmh(null), '—');
    });

    test('formatMeters / formatKnots / formatMph round and dash null', () {
      expect(UnitConverters.formatMeters(10668), '10668');
      expect(UnitConverters.formatMeters(null), '—');
      expect(UnitConverters.formatKnots(100), '194'); // 100 * 1.94384
      expect(UnitConverters.formatKnots(null), '—');
      expect(UnitConverters.formatMph(100), '224'); // 100 * 2.23694
      expect(UnitConverters.formatMph(null), '—');
    });

    test('formatVerticalRate signs, rounds to 50 ft/min, and dashes null', () {
      expect(UnitConverters.formatVerticalRate(10), '+1950'); // 1968 → 1950
      expect(UnitConverters.formatVerticalRate(-10), '-1950');
      expect(UnitConverters.formatVerticalRate(0), '0');
      expect(UnitConverters.formatVerticalRate(null), '—');
    });
  });
}
