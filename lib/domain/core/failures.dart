import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = 'Unexpected error occurred']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication error occurred']) : super(message);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([String message = 'Email is already in use']) : super(message);
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure([String message = 'Invalid email address']) : super(message);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([String message = 'Password is too weak']) : super(message);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([String message = 'User not found']) : super(message);
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure([String message = 'Wrong password']) : super(message);
} 