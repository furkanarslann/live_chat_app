import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/chat/chat_repository.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final FirebaseAuth _authService;

  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatCubit(this._chatRepository, this._authService)
      : super(const ChatState()) {
    initialize();
  }

  void initialize() {
    // Fetch initial conversations and their participants
    _fetchConversationParticipants();
    // Load unread message counts
    _loadUnreadMessageCounts();
    // Start watching conversations
    _watchConversations();
  }

  void _watchConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatRepository.watchConversations().listen(
      (failureOrConversations) async {
        emit(state.copyWith(
          failureOrConversationsOpt: Some(failureOrConversations),
        ));

        // Refresh unread counts when conversations are updated
        await _loadUnreadMessageCounts();
      },
    );
  }

  Future<void> clearConversationChatHistory(String conversationId) async {
    await _chatRepository.clearConversationChatHistory(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    await _chatRepository.deleteConversation(conversationId);
  }

  void changeConversationFilter(ChatConversationFilter filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  Future<void> _fetchConversationParticipants() async {
    // Ensure conversations are loaded first
    if (state.failureOrConversationsOpt.isNone()) {
      final failOrConversations = await _chatRepository.getConversations();
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
          return participantId != _authService.currentUser?.uid;
        }),
      );
    }

    // Batch load all participants efficiently
    if (allParticipantIds.isNotEmpty) {
      final batchParticipants =
          await _chatRepository.getConversationParticipants(
        allParticipantIds.toList(),
      );
      emit(state.copyWith(
        participantsMap: Map<String, User>.from(batchParticipants),
      ));
    } else {
      emit(state.copyWith(participantsMap: <String, User>{}));
    }
  }

  Future<void> _loadUnreadMessageCounts() async {
    final unreadCountMap = await _chatRepository.getUnreadMessagesCount();
    emit(state.copyWith(unreadCountMap: unreadCountMap));
  }

  void selectConversation(String conversationId) {
    emit(state.copyWith(selectedConversationIdOpt: Some(conversationId)));
  }

  Future<void> loadSingleParticipant(String participantId) async {
    final user =
        await _chatRepository.getConversationParticipants([participantId]);
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
    final failureOrMessages = await _chatRepository.getMessages(conversationId);
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
    _messagesSubscription =
        _chatRepository.watchMessages(conversationId).listen(
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

    emit(state.copyWith(
      isSending: true,
      failOrSendSuccessOpt: none(),
    ));

    final result = await _chatRepository.sendMessage(
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
    await _chatRepository.markMessagesAsRead(messageIds);
  }

  /// Automatically mark messages as read when user is viewing the conversation
  Future<void> markMessagesAsReadOnView(
    String conversationId,
  ) async {
    await _chatRepository.markConversationMessagesAsRead(conversationId);
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
