import 'package:flutter_test/flutter_test.dart';
import 'package:skytracker/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () => expect(Validators.email(''), 'validation.emailRequired'));
    test('rejects malformed', () => expect(Validators.email('not-an-email'), 'validation.emailInvalid'));
    test('accepts valid', () => expect(Validators.email('pilot@sky.io'), isNull));
    test('trims surrounding whitespace', () => expect(Validators.email('  pilot@sky.io '), isNull));
  });

  group('Validators.password', () {
    test('rejects empty', () => expect(Validators.password(''), 'validation.passwordRequired'));
    test('rejects too short', () => expect(Validators.password('12345'), 'validation.passwordTooShort'));
    test('accepts 6+ chars', () => expect(Validators.password('123456'), isNull));
  });

  group('Validators.confirmPassword', () {
    test('rejects mismatch', () => expect(Validators.confirmPassword('abc123', 'xyz789'), 'validation.passwordMismatch'));
    test('accepts match', () => expect(Validators.confirmPassword('abc123', 'abc123'), isNull));
  });

  group('Validators.fullName', () {
    test('rejects empty', () => expect(Validators.fullName(''), 'validation.nameRequired'));
    test('rejects single char', () => expect(Validators.fullName('A'), 'validation.nameTooShort'));
    test('accepts a real name', () => expect(Validators.fullName('Ada Lovelace'), isNull));
  });
}
