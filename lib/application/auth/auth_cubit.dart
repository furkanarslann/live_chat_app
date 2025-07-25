import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/auth/auth_state.dart';
import 'package:live_chat_app/domain/models/user.dart';
import 'package:live_chat_app/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;
  StreamSubscription<Option<User>>? _authStateSubscription;

  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userIdKey = 'userId';

  AuthCubit({
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  })  : _authRepository = authRepository,
        _prefs = prefs,
        super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    _authStateSubscription =
        _authRepository.authStateChanges.listen((userOption) {
      userOption.fold(
        () => emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        )),
        (user) => emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        )),
      );
    });

    // Check if user was previously logged in
    final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    if (isLoggedIn) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        () {
          // No user found, clear preferences
          _prefs.remove(_isLoggedInKey);
          _prefs.remove(_userIdKey);
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
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
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
        // Save login state
        _prefs.setBool(_isLoggedInKey, true);
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
        // Save login state
        _prefs.setBool(_isLoggedInKey, true);
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
    emit(state.copyWith(
      isSubmitting: true,
      failureOption: none(),
    ));

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        failureOption: some(failure),
      )),
      (_) {
        // Clear login state
        _prefs.remove(_isLoggedInKey);
        _prefs.remove(_userIdKey);

        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          isSubmitting: false,
          failureOption: none(),
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
