import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:live_chat_app/domain/core/failures.dart';
import 'package:live_chat_app/domain/models/user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final bool isSubmitting;
  final Option<Failure> failureOption;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isSubmitting = false,
    this.failureOption = const None(),
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isSubmitting,
    Option<Failure>? failureOption,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failureOption: failureOption ?? this.failureOption,
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, failureOption];
}
