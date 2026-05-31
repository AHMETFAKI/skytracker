import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/core/config/data_source.dart';

void main() {
  group('DataSource.fromString', () {
    test('parses remote', () => expect(DataSource.fromString('remote'), DataSource.remote));
    test('is case-insensitive', () => expect(DataSource.fromString('REMOTE'), DataSource.remote));
    test('trims whitespace', () => expect(DataSource.fromString('  remote '), DataSource.remote));
    test('unknown falls back to mock', () => expect(DataSource.fromString('garbage'), DataSource.mock));
    test('null falls back to mock', () => expect(DataSource.fromString(null), DataSource.mock));
  });

  group('DataSource.resolve precedence', () {
    test('dart-define wins over .env', () {
      expect(
        DataSource.resolve(define: 'remote', envValue: 'mock'),
        DataSource.remote,
      );
    });

    test('falls back to .env when define is empty', () {
      expect(
        DataSource.resolve(define: '', envValue: 'remote'),
        DataSource.remote,
      );
    });

    test('blank define is treated as absent', () {
      expect(
        DataSource.resolve(define: '   ', envValue: 'remote'),
        DataSource.remote,
      );
    });

    test('defaults to mock when neither is set', () {
      expect(
        DataSource.resolve(define: ''),
        DataSource.mock,
      );
    });

    test('case-insensitive via fromString', () {
      expect(
        DataSource.resolve(define: 'REMOTE'),
        DataSource.remote,
      );
    });

    test('unknown define value falls back to mock', () {
      expect(
        DataSource.resolve(define: 'garbage', envValue: 'remote'),
        DataSource.mock,
      );
    });
  });
}
