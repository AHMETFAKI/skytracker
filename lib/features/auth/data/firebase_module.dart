import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

/// Provides the Firebase singletons. Resolved lazily so a mock-first run with
/// no Firebase config never touches `FirebaseAuth.instance` (which would throw
/// without a default app) until an auth feature is actually used.
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
