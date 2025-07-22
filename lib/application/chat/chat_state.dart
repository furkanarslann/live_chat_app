import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final Option<Either<Failure, List<ChatConversation>>> failureOrConversations;
  final Option<Either<Failure, List<ChatMessage>>> failureOrMessages;
  final Option<String> selectedConversationId;
  final bool isSending;
  final Option<Either<Failure, Unit>> failureOrSuccess;

  const ChatState({
    this.isLoading = false,
    this.failureOrConversations = const None(),
    this.failureOrMessages = const None(),
    this.selectedConversationId = const None(),
    this.isSending = false,
    this.failureOrSuccess = const None(),
  });

  @override
  List<Object?> get props => [
        isLoading,
        failureOrConversations,
        failureOrMessages,
        selectedConversationId,
        isSending,
        failureOrSuccess,
      ];

  ChatState copyWith({
    bool? isLoading,
    Option<Either<Failure, List<ChatConversation>>>? failureOrConversations,
    Option<Either<Failure, List<ChatMessage>>>? failureOrMessages,
    Option<String>? selectedConversationId,
    bool? isSending,
    Option<Either<Failure, Unit>>? failureOrSuccess,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      failureOrConversations:
          failureOrConversations ?? this.failureOrConversations,
      failureOrMessages: failureOrMessages ?? this.failureOrMessages,
      selectedConversationId:
          selectedConversationId ?? this.selectedConversationId,
      isSending: isSending ?? this.isSending,
      failureOrSuccess: failureOrSuccess ?? this.failureOrSuccess,
    );
  }
}
