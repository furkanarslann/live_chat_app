import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/models/user.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';

class ChatState extends Equatable {
  // Conversations related state
  final bool isLoading;
  final Option<Either<Failure, List<ChatConversation>>>
      failureOrConversationsOpt;
  final Option<String> selectedConversationIdOpt;
  final Map<String, User> participantsMap;
  final Map<String, int> unreadCountMap;

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
      ];

  List<ChatConversation> get conversationsOrEmpty {
    return failureOrConversationsOpt
        .getOrElse(() => right([]))
        .getOrElse(() => []);
  }

  List<ChatMessage> get messagesOrEmpty {
    return failureOrMessagesOpt.getOrElse(() => right([])).getOrElse(() => []);
  }

  User? findParticipant(String participantId) {
    return participantsMap[participantId];
  }

  int getUnreadCount(String conversationId) {
    return unreadCountMap[conversationId] ?? 0;
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
    );
  }
}
