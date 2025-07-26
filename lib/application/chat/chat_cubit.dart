import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatCubit(this._repository) : super(const ChatState()) {
    _watchConversations();
  }

  Future<void> selectConversation(String conversationId) async {
    emit(state.copyWith(selectedConversationIdOpt: Some(conversationId)));
  }

  void _watchConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _repository.watchConversations().listen(
      (failureOrConversations) {
        emit(state.copyWith(
          failureOrConversationsOpt: Some(failureOrConversations),
        ));
      },
    );
  }

  Future<void> watchSelectedConversationMessages() async {
    if (state.selectedConversationIdOpt.isNone()) return;

    final conversationId = state.selectedConversationIdOpt.toNullable()!;

    // First fetch messages
    final failureOrMessages = await _repository.getMessages(conversationId);
    emit(state.copyWith(
      failureOrMessagesOpt: Some(failureOrMessages),
    ));

    // Then start watching for updates
    _watchMessages(conversationId);
  }

  void _watchMessages(String conversationId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.watchMessages(conversationId).listen(
      (failureOrMessages) {
        emit(state.copyWith(
          failureOrMessagesOpt: Some(failureOrMessages),
        ));
      },
    );
  }

  Future<void> sendMessage(String content) async {
    if (state.selectedConversationIdOpt.isNone()) return;

    final conversationId = state.selectedConversationIdOpt.toNullable()!;

    // Get the participant ID from the conversations list
    final participantId = state.failureOrConversationsOpt.fold(
      () => null,
      (failureOrConversations) => failureOrConversations.fold(
        (failure) => null,
        (conversations) {
          final conversation = conversations.firstWhere(
            (conv) => conv.id == conversationId,
            orElse: () => throw const UnexpectedFailure(),
          );
          return conversation.participantId;
        },
      ),
    );

    if (participantId == null) {
      emit(state.copyWith(
        failureOrSuccessOpt: some(left(const UnexpectedFailure())),
      ));
      return;
    }

    emit(state.copyWith(isSending: true));

    final result = await _repository.sendMessage(
      content: content,
      participantId: participantId,
    );

    emit(state.copyWith(
      isSending: false,
      failureOrSuccessOpt: Some(result),
    ));
  }

  Future<void> markMessageAsRead(String messageId) async {
    final result = await _repository.markMessageAsRead(messageId);
    emit(state.copyWith(failureOrSuccessOpt: Some(result)));
  }

  Future<void> clearChatHistory(String conversationId) async {
    await _repository.clearChatHistory(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    await _repository.deleteConversation(conversationId);
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
