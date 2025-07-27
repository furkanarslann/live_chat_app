import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import '../../domain/core/failures.dart';
import '../../domain/chat/chat_conversation.dart';
import '../../domain/chat/chat_message.dart';

enum ChatFilter {
  all,
  unread,
  favorites,
  groups,
}

class ChatState extends Equatable {
  // Conversations related state
  final bool isLoading;
  final Option<Either<Failure, List<ChatConversation>>>
      failureOrConversationsOpt;
  final Option<String> selectedConversationIdOpt;
  final Map<String, User> participantsMap;
  final Map<String, int> unreadCountMap;

  // Filter state
  final ChatFilter activeFilter;

  // Messages related state
  final Option<Either<Failure, List<ChatMessage>>> failureOrMessagesOpt;
  final bool isSending;
  final Option<Either<Failure, Unit>> failOrSendSuccessOpt;

  const ChatState({
    this.isLoading = false,
    this.participantsMap = const {},
    this.unreadCountMap = const {},
    this.failureOrConversationsOpt = const None(),
    this.failureOrMessagesOpt = const None(),
    this.selectedConversationIdOpt = const None(),
    this.isSending = false,
    this.failOrSendSuccessOpt = const None(),
    this.activeFilter = ChatFilter.all,
  });

  @override
  List<Object?> get props => [
        isLoading,
        failureOrConversationsOpt,
        failureOrMessagesOpt,
        selectedConversationIdOpt,
        isSending,
        failOrSendSuccessOpt,
        participantsMap,
        unreadCountMap,
        activeFilter,
      ];

  List<ChatConversation> get conversationsOrEmpty {
    return failureOrConversationsOpt
        .getOrElse(() => right([]))
        .getOrElse(() => []);
  }

  List<ChatMessage> get messagesOrEmpty {
    return failureOrMessagesOpt.getOrElse(() => right([])).getOrElse(() => []);
  }

  List<ChatConversation> getNonArchivedConversations(User currentUser) {
    final conversations = conversationsOrEmpty;

    // Only show conversations that have messages
    final conversationsWithMessages =
        conversations.where((conv) => conv.lastMessage != null).toList();

    final nonArchived = conversationsWithMessages
        .where((conv) => !currentUser.chatPreferences.isArchived(conv.id))
        .toList();

    // Apply active filter
    final filteredConversations = _applyFilter(nonArchived, currentUser);

    filteredConversations.sort((a, b) {
      final aPinned = currentUser.chatPreferences.isPinned(a.id);
      final bPinned = currentUser.chatPreferences.isPinned(b.id);
      if (aPinned != bPinned) return aPinned ? -1 : 1;

      final aTime = a.lastMessage?.timestamp ?? a.createdAt ?? DateTime(0);
      final bTime = b.lastMessage?.timestamp ?? b.createdAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    return filteredConversations;
  }

  List<ChatConversation> _applyFilter(
    List<ChatConversation> conversations,
    User currentUser,
  ) {
    switch (activeFilter) {
      case ChatFilter.all:
        return conversations;
      case ChatFilter.unread:
        return conversations.where((conv) {
          final unreadCount = getUnreadCount(conv.id);
          return unreadCount > 0;
        }).toList();
      case ChatFilter.favorites:
        // For now, return empty list as favorite functionality is not implemented
        return [];
      case ChatFilter.groups:
        // For now, return empty list as group functionality is not implemented
        return [];
    }
  }

  User? findParticipant(String participantId) {
    return participantsMap[participantId];
  }

  int getUnreadCount(String conversationId) {
    return unreadCountMap[conversationId] ?? 0;
  }

  ChatMessage? getLastMessage(String conversationId) {
    final conv = conversationsOrEmpty.firstWhere((c) => c.id == conversationId);
    return conv.lastMessage;
  }

  ChatState copyWith({
    bool? isLoading,
    Option<Either<Failure, List<ChatConversation>>>? failureOrConversationsOpt,
    Option<Either<Failure, List<ChatMessage>>>? failureOrMessagesOpt,
    Option<String>? selectedConversationIdOpt,
    bool? isSending,
    Option<Either<Failure, Unit>>? failOrSendSuccessOpt,
    Map<String, User>? participantsMap,
    Map<String, int>? unreadCountMap,
    ChatFilter? activeFilter,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      failureOrConversationsOpt:
          failureOrConversationsOpt ?? this.failureOrConversationsOpt,
      failureOrMessagesOpt: failureOrMessagesOpt ?? this.failureOrMessagesOpt,
      selectedConversationIdOpt:
          selectedConversationIdOpt ?? this.selectedConversationIdOpt,
      isSending: isSending ?? this.isSending,
      failOrSendSuccessOpt: failOrSendSuccessOpt ?? this.failOrSendSuccessOpt,
      participantsMap: participantsMap ?? this.participantsMap,
      unreadCountMap: unreadCountMap ?? this.unreadCountMap,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}
