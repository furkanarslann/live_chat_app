import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/domain/models/user.dart';
import 'package:live_chat_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Email validation regex
  final _emailRegex = RegExp(
    r'^(?:[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?!yok\.com$)((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validate email format
      if (!_emailRegex.hasMatch(email)) {
        return left(const InvalidEmailFailure());
      }

      // Check if email already exists in Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return left(const EmailAlreadyInUseFailure());
      }

      // Create the user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return left(const UnexpectedFailure('Failed to create user'));
      }

      // Split name into first and last name
      final names = name.trim().split(' ');
      final firstName = names.first;
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      // Create user document in Firestore
      final user = User(
        id: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
        photoUrl: null,
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());

      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email format
      if (!_emailRegex.hasMatch(email)) {
        return left(const InvalidEmailFailure());
      }

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return left(const UnexpectedFailure('Failed to sign in'));
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return left(const UserNotFoundFailure());
      }

      final user = User.fromJson(userDoc.data()!);

      // Update user's online status and last seen
      await _firestore.collection('users').doc(user.id).update({
        'isOnline': true,
        'lastSeen': DateTime.now().toIso8601String(),
      });

      return right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return left(const UserNotFoundFailure());
        case 'wrong-password':
          return left(const WrongPasswordFailure());
        default:
          return left(AuthFailure(e.message ?? 'Authentication failed'));
      }
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Update user's online status and last seen before signing out
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': false,
          'lastSeen': DateTime.now().toIso8601String(),
        });
      }

      await _firebaseAuth.signOut();
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Option<User>> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return none();
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return none();
      }

      return some(User.fromJson(userDoc.data()!));
    } catch (_) {
      return none();
    }
  }

  @override
  Stream<Option<User>> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return none();
      }

      try {
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          return none();
        }

        return some(User.fromJson(userDoc.data()!));
      } catch (_) {
        return none();
      }
    });
  }
}
