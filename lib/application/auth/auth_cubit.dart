import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:live_chat_app/application/auth/auth_state.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/domain/auth/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;
  StreamSubscription<Option<User>>? _authStateSubscription;

  static const String _userIdKey = 'userId';

  AuthCubit({
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  })  : _authRepository = authRepository,
        _prefs = prefs,
        super(const AuthState());

  Future<void> init() async {
    final userId = _prefs.getString(_userIdKey);

    if (userId == null) {
      // If no saved session in SharedPreferences, ensure Firebase is signed out
      await _authRepository.signOut();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    // Only if we have a valid userId in SharedPreferences, check Firebase
    final result = await _authRepository.getCurrentUser();
    result.fold(
      () {
        // No user found or error, clear preferences and ensure signed out
        _prefs.remove(_userIdKey);
        _authRepository.signOut();
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        ));
      },
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );

    // Listen to auth state changes only after initial setup
    _authStateSubscription =
        _authRepository.authStateChanges.listen((userOption) {
      userOption.fold(
        () {
          // Clear preferences when user is logged out
          _prefs.remove(_userIdKey);
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
          ));
        },
        (user) {
          // Only update if we have a valid session in SharedPreferences
          if (_prefs.getString(_userIdKey) != null) {
            emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            ));
          } else {
            // If no valid session in SharedPreferences, sign out from Firebase
            _authRepository.signOut();
          }
        },
      );
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(
      isSubmitting: true,
      failureOption: none(),
    ));

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        isSubmitting: false,
        failureOption: some(failure),
      )),
      (user) {
        // Save user ID
        _prefs.setString(_userIdKey, user.id);

        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isSubmitting: false,
          failureOption: none(),
        ));
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(state.copyWith(
      isSubmitting: true,
      failureOption: none(),
    ));

    final result = await _authRepository.register(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        isSubmitting: false,
        failureOption: some(failure),
      )),
      (user) {
        // Save user ID
        _prefs.setString(_userIdKey, user.id);

        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isSubmitting: false,
          failureOption: none(),
        ));
      },
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSubmitting: true));

    await _authRepository.signOut();

    // Clear user ID
    _prefs.remove(_userIdKey);

    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      isSubmitting: false,
    ));
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
