import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../error/failure.dart';

/// Localized message for a domain [Failure]; falls back to the generic
/// unknown-error text for anything else.
String failureMessage(Object? error) {
  final key = error is Failure ? error.i18nKey : 'error.unknown';
  return key.tr();
}

/// Shows a localized snackbar for a domain [Failure]. Anything that is not a
/// `Failure` falls back to the generic unknown-error message.
void showFailureSnackBar(BuildContext context, Object? error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(failureMessage(error))));
}
