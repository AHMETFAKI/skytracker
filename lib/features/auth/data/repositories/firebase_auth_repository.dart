import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../auth_failure_mapper.dart';

/// Firebase-backed [IAuthRepository]: Firebase Auth for identity and the
/// `users/{uid}` Firestore document for the profile. Every method funnels
/// Firebase exceptions through [AuthFailureMapper] and returns `Either`.
@LazySingleton(as: IAuthRepository)
class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  AppUser? get currentUser => _toIdentity(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toIdentity);

  AppUser? _toIdentity(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
    );
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(fullName);
      await _users.doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return right(
        AppUser(
          uid: user.uid,
          email: email,
          fullName: fullName,
          createdAt: DateTime.now(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      return left(AuthFailureMapper.fromAuth(e));
    } on FirebaseException catch (e) {
      return left(AuthFailureMapper.fromFirestore(e));
    } catch (_) {
      return left(const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      return getProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailureMapper.fromAuth(e));
    } catch (_) {
      return left(const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _auth.signOut();
      return right(unit);
    } catch (_) {
      return left(const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, AppUser>> getProfile(String uid) async {
    try {
      final snapshot = await _users.doc(uid).get();
      final data = snapshot.data();
      if (data == null) return left(const Failure.cache());
      return right(
        AppUser(
          uid: uid,
          email: (data['email'] as String?) ?? '',
          fullName: (data['fullName'] as String?) ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        ),
      );
    } on FirebaseException catch (e) {
      return left(AuthFailureMapper.fromFirestore(e));
    } catch (_) {
      return left(const Failure.unknown());
    }
  }

  @override
  Future<Either<Failure, AppUser>> updateFullName({
    required String uid,
    required String fullName,
  }) async {
    try {
      await _users.doc(uid).update({'fullName': fullName});
      await _auth.currentUser?.updateDisplayName(fullName);
      return getProfile(uid);
    } on FirebaseException catch (e) {
      return left(AuthFailureMapper.fromFirestore(e));
    } catch (_) {
      return left(const Failure.unknown());
    }
  }
}
