import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/chat/chat_repository.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatCubit(this._repository) : super(const ChatState()) {
    _watchConversations();
  }

  void selectConversation(String conversationId) {
    emit(state.copyWith(selectedConversationIdOpt: Some(conversationId)));
  }

  void _watchConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _repository.watchConversations().listen(
      (failureOrConversations) async {
        emit(state.copyWith(
          failureOrConversationsOpt: Some(failureOrConversations),
        ));

        // Refresh unread counts when conversations are updated
        await loadUnreadMessageCounts();
      },
    );
  }

  Future<void> loadParticipantsForConversations({
    required String currentUserId,
  }) async {
    // Ensure conversations are loaded first
    if (state.failureOrConversationsOpt.isNone()) {
      final failOrConversations = await _repository.getConversations();
      emit(
        state.copyWith(failureOrConversationsOpt: Some(failOrConversations)),
      );
    }

    final conversations = state.conversationsOrEmpty;
    if (conversations.isEmpty) {
      emit(state.copyWith(participantsMap: <String, User>{}));
      return;
    }

    // Extract all unique participant IDs from all conversations, excluding current user
    final allParticipantIds = <String>{};
    for (final conversation in conversations) {
      allParticipantIds.addAll(
        conversation.participants.where((participantId) {
          return participantId != currentUserId;
        }),
      );
    }

    // Batch load all participants efficiently
    if (allParticipantIds.isNotEmpty) {
      final batchParticipants = await _repository.getConversationParticipants(
        allParticipantIds.toList(),
      );
      emit(state.copyWith(
          participantsMap: Map<String, User>.from(batchParticipants)));
    } else {
      emit(state.copyWith(participantsMap: <String, User>{}));
    }
  }

  Future<void> loadUnreadMessageCounts() async {
    final unreadCountMap = await _repository.getUnreadMessagesCount();
    emit(state.copyWith(unreadCountMap: unreadCountMap));
  }

  Future<void> loadSingleParticipant(String participantId) async {
    final user = await _repository.getConversationParticipants([participantId]);
    if (user.isNotEmpty) {
      emit(state.copyWith(
        participantsMap: {...state.participantsMap, ...user},
      ));
    }
  }

  Future<void> watchSelectedConversationMessages() async {
    if (state.selectedConversationIdOpt.isNone()) return;

    final conversationId = state.selectedConversationIdOpt.toNullable()!;

    // First fetch messages
    final failureOrMessages = await _repository.getMessages(conversationId);
    emit(state.copyWith(
      failureOrMessagesOpt: Some(failureOrMessages),
    ));

    // Mark messages as read when user opens conversation
    await markMessagesAsReadOnView(conversationId);

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

  Future<void> sendMessage(String content, String participantId) async {
    if (state.selectedConversationIdOpt.isNone()) return;

    final conversationId = state.selectedConversationIdOpt.toNullable()!;

    emit(state.copyWith(isSending: true));

    final result = await _repository.sendMessage(
      content: content,
      participantId: participantId,
      conversationId: conversationId,
    );

    emit(state.copyWith(
      isSending: false,
      failOrSendSuccessOpt: Some(result),
    ));
  }

  /// Mark all unread messages as read when conversation is opened
  Future<void> markMessagesAsRead(List<String> messageIds) async {
    await _repository.markMessagesAsRead(messageIds);
  }

  /// Automatically mark messages as read when user is viewing the conversation
  Future<void> markMessagesAsReadOnView(
    String conversationId,
  ) async {
    await _repository.markConversationMessagesAsRead(conversationId);
  }

  Future<void> clearConversationChatHistory(String conversationId) async {
    await _repository.clearConversationChatHistory(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    await _repository.deleteConversation(conversationId);
  }

  Future<void> clearErrorState() async {
    emit(state.copyWith(failOrSendSuccessOpt: const None()));
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
