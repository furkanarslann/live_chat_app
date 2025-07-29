import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/chat/chat_repository.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:injectable/injectable.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';

@injectable
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
    // Start watching conversations first
    _watchConversations();
  }

  void _watchConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _chatRepository.watchConversations().listen(
      (failureOrConversations) async {
        emit(state.copyWith(
          failureOrConversationsOpt: Some(failureOrConversations),
        ));

        // Fetch participants for conversations (including new ones)
        await _fetchConversationParticipants();

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

    // Filter out participants that are already loaded
    final newParticipantIds = allParticipantIds
        .where((id) => !state.participantsMap.containsKey(id))
        .toList();

    // Only load participants that aren't already in the map
    if (newParticipantIds.isNotEmpty) {
      final batchParticipants =
          await _chatRepository.getConversationParticipants(
        newParticipantIds,
      );

      // Merge new participants with existing ones
      final updatedParticipantsMap =
          Map<String, User>.from(state.participantsMap);
      updatedParticipantsMap.addAll(batchParticipants);

      emit(state.copyWith(
        participantsMap: updatedParticipantsMap,
      ));
    }
  }

  Future<void> _loadUnreadMessageCounts() async {
    final unreadCountMap = await _chatRepository.getUnreadMessagesCount();
    emit(state.copyWith(unreadCountMap: unreadCountMap));
  }

  void selectConversation(String conversationId) {
    // Cancel any existing message subscription
    _messagesSubscription?.cancel();

    // Clear previous messages and set new conversation
    emit(state.copyWith(
      selectedConversationIdOpt: Some(conversationId),
      failureOrMessagesOpt: const None(),
      isSending: false,
      failOrSendSuccessOpt: const None(),
    ));
  }

  Future<void> loadSingleParticipant(String participantId) async {
    // Skip if participant is already loaded
    if (state.participantsMap.containsKey(participantId)) {
      return;
    }

    final user =
        await _chatRepository.getConversationParticipants([participantId]);
    if (user.isNotEmpty) {
      emit(state.copyWith(
        participantsMap: {...state.participantsMap, ...user},
      ));
    }
  }

  Future<void> watchSelectedConversationMessages() async {
    // Cancel any existing subscription first
    _messagesSubscription?.cancel();

    if (state.selectedConversationIdOpt.isNone()) return;
    final conversationId = state.selectedConversationIdOpt.toNullable()!;

    // First fetch messages
    final failureOrMessages = await _chatRepository.getMessages(conversationId);
    emit(state.copyWith(
      failureOrMessagesOpt: Some(failureOrMessages),
    ));

    // Mark messages as read when user opens conversation
    await markConversationMessagesAsRead(conversationId);

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
  Future<void> markConversationMessagesAsRead(String conversationId) async {
    await _chatRepository.markConversationMessagesAsRead(conversationId);
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
