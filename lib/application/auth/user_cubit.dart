import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/core/failures.dart';
import '../../domain/auth/user.dart';
import '../../domain/auth/user_repository.dart';

part 'user_state.dart';

@injectable
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;
  StreamSubscription? _userSubscription;

  UserCubit(this._repository) : super(const UserState()) {
    _watchCurrentUser();
  }

  void _watchCurrentUser() {
    emit(state.copyWith(isLoading: true));

    _userSubscription?.cancel();
    _userSubscription = _repository.watchCurrentUser().listen(
      (failureOrUser) {
        emit(state.copyWith(
          isLoading: false,
          failureOrUserOpt: some(failureOrUser),
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          failureOrUserOpt: some(left(const UnexpectedFailure())),
        ));
      },
    );
  }

  Future<void> togglePinConversation(String conversationId) async {
    final user = state.user;
    if (user == null) return;

    // Optimistically update the state
    final updatedPreferences = user.chatPreferences.copyWith(
      pinnedConversations: user.chatPreferences.isPinned(conversationId)
          ? user.chatPreferences.pinnedConversations
              .where((id) => id != conversationId)
              .toList()
          : [...user.chatPreferences.pinnedConversations, conversationId],
    );

    final updatedUser = user.copyWith(chatPreferences: updatedPreferences);

    emit(state.copyWith(
      failureOrUserOpt: some(right(updatedUser)),
    ));

    // Update Firestore
    await _repository.togglePinConversation(conversationId);
  }

  Future<void> toggleArchiveConversation(String conversationId) async {
    final user = state.user;
    if (user == null) return;

    // Optimistically update the state
    final updatedPreferences = user.chatPreferences.copyWith(
      archivedConversations: user.chatPreferences.isArchived(conversationId)
          ? user.chatPreferences.archivedConversations
              .where((id) => id != conversationId)
              .toList()
          : [...user.chatPreferences.archivedConversations, conversationId],
      // Unpin when archiving
      pinnedConversations: user.chatPreferences.pinnedConversations
          .where((id) => id != conversationId)
          .toList(),
    );

    final updatedUser = user.copyWith(chatPreferences: updatedPreferences);

    emit(state.copyWith(
      failureOrUserOpt: some(right(updatedUser)),
    ));

    // Update Firestore
    await _repository.toggleArchiveConversation(conversationId);
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
