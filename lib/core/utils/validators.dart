/// Form field validators returning an i18n key (or null when valid) so the
/// presentation layer can localize the message. Used by auth forms in Phase 5.
abstract final class Validators {
  const Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
  );

  /// Required, well-formed email.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'validation.emailRequired';
    if (!_emailRegExp.hasMatch(v)) return 'validation.emailInvalid';
    return null;
  }

  /// Required, minimum 6 characters (Firebase auth minimum).
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'validation.passwordRequired';
    if (v.length < 6) return 'validation.passwordTooShort';
    return null;
  }

  /// Confirm-password must equal the original.
  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'validation.passwordRequired';
    if (value != original) return 'validation.passwordMismatch';
    return null;
  }

  /// Required, non-blank full name.
  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'validation.nameRequired';
    if (v.length < 2) return 'validation.nameTooShort';
    return null;
  }
}
