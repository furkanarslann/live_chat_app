import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final Option<Either<Failure, List<ChatConversation>>>
      failureOrConversationsOpt;
  final Option<Either<Failure, List<ChatMessage>>> failureOrMessagesOpt;
  final Option<String> selectedConversationIdOpt;
  final bool isSending;
  final Option<Either<Failure, Unit>> failOrSendSuccessOpt;

  const ChatState({
    this.isLoading = false,
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
      ];

  List<ChatConversation> get conversationsOrEmpty {
    return failureOrConversationsOpt
        .getOrElse(() => right([]))
        .getOrElse(() => []);
  }

  List<ChatMessage> get messagesOrEmpty {
    return failureOrMessagesOpt.getOrElse(() => right([])).getOrElse(() => []);
  }

  ChatState copyWith({
    bool? isLoading,
    Option<Either<Failure, List<ChatConversation>>>? failureOrConversationsOpt,
    Option<Either<Failure, List<ChatMessage>>>? failureOrMessagesOpt,
    Option<String>? selectedConversationIdOpt,
    bool? isSending,
    Option<Either<Failure, Unit>>? failOrSendSuccessOpt,
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
    );
  }
}
