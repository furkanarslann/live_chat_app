import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';

extension BuildContextAuthX on BuildContext {
  /// Checks if the user is authenticated.
  bool get isAuthenticated {
    final authCubit = read<AuthCubit>();
    return authCubit.state.isAuthenticated;
  }

  /// Gets the current user's ID.
  String get userId {
    assert(isAuthenticated, 'User must be authenticated to access userId');
    final authCubit = read<AuthCubit>();
    return authCubit.state.user!.id;
  }
}
