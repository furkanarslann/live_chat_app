import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/domain/auth/user.dart';

abstract class AuthRepository {
  /// Registers a new user with email and password
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Signs in a user with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Signs out the current user
  Future<Either<Failure, Unit>> signOut();

  /// Returns the current authenticated user or null
  Future<Option<User>> getCurrentUser();

  /// Stream of auth state changes
  Stream<Option<User>> get authStateChanges;
}
