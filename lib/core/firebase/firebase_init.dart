import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Whether a default [FirebaseApp] is available this run.
///
/// In the mock-first flow the app must run with no Firebase config at all
/// (no `google-services.json`), so auth/profile features check this before
/// touching Firebase and degrade gracefully when it is `false`.
bool get isFirebaseReady => Firebase.apps.isNotEmpty;

/// Initializes Firebase if the platform has it configured. Relies on
/// `google-services.json` (Android) processed by the google-services Gradle
/// plugin; when that config is absent the call throws and we simply stay in
/// the no-Firebase state instead of crashing the app.
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Firebase not configured — auth features disabled: $error');
    }
  }
}
