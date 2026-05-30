import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/features/flights/data/dtos/flight_state_dto.dart';

void main() {
  group('FlightStateDto.fromStateVector', () {
    test('maps a full OpenSky state vector by index', () {
      final dto = FlightStateDto.fromStateVector([
        '4b1817', // 0 icao24
        'SWR123  ', // 1 callsign (padded)
        'Switzerland', // 2 origin_country
        1717000000, // 3 time_position
        1717000000, // 4 last_contact
        8.5417, // 5 longitude
        47.4584, // 6 latitude
        11277.6, // 7 baro_altitude
        false, // 8 on_ground
        241.32, // 9 velocity
        86.5, // 10 true_track
        0.0, // 11 vertical_rate
        null, // 12 sensors
        11582.4, // 13 geo_altitude
        '1000', // 14 squawk
        false, // 15 spi
        0, // 16 position_source
      ]);

      expect(dto.icao24, '4b1817');
      expect(dto.callsign, 'SWR123'); // trimmed
      expect(dto.originCountry, 'Switzerland');
      expect(dto.longitude, 8.5417);
      expect(dto.latitude, 47.4584);
      expect(dto.baroAltitude, 11277.6);
      expect(dto.onGround, false);
      expect(dto.velocity, 241.32);
      expect(dto.trueTrack, 86.5);
      expect(dto.geoAltitude, 11582.4);
    });

    test('coerces integer cells to double', () {
      final dto = FlightStateDto.fromStateVector([
        'abc123',
        'TEST',
        'Country',
        0,
        0,
        10, // int longitude
        20, // int latitude
        null,
        true,
        null,
        null,
        null,
        null,
        null,
      ]);

      expect(dto.longitude, 10.0);
      expect(dto.latitude, 20.0);
      expect(dto.onGround, true);
    });

    test('blank callsign becomes null', () {
      final dto = FlightStateDto.fromStateVector([
        'abc123',
        '   ',
        'Country',
        0,
        0,
        1.0,
        2.0,
      ]);

      expect(dto.callsign, isNull);
    });
  });

  group('FlightStateDto.toEntity', () {
    test('produces an entity when a position is present', () {
      final dto = FlightStateDto.fromStateVector([
        'abc123',
        'CALL',
        'Country',
        0,
        0,
        8.0,
        47.0,
        9000.0,
        false,
        200.0,
        90.0,
        0.0,
        null,
        9100.0,
      ]);

      final entity = dto.toEntity();

      expect(entity, isNotNull);
      expect(entity!.icao24, 'abc123');
      expect(entity.latitude, 47.0);
      expect(entity.longitude, 8.0);
      expect(entity.altitude, 9100.0); // geo preferred over baro
      expect(entity.displayCallsign, 'CALL');
    });

    test('returns null when latitude or longitude is missing', () {
      final dto = FlightStateDto.fromStateVector([
        'abc123',
        'CALL',
        'Country',
        0,
        0,
        null, // longitude
        null, // latitude
      ]);

      expect(dto.toEntity(), isNull);
    });

    test('falls back to barometric altitude when geo is null', () {
      final dto = FlightStateDto.fromStateVector([
        'abc123',
        'CALL',
        'Country',
        0,
        0,
        8.0,
        47.0,
        8000.0, // baro
        false,
        null,
        null,
        null,
        null,
        null, // geo null
      ]);

      expect(dto.toEntity()!.altitude, 8000.0);
    });
  });
}
