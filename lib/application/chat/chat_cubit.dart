import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatCubit(this._repository) : super(const ChatState()) {
    _initializeConversations();
    _watchConversations();
    // _repository.startAutoMessages();
  }

  Future<void> _initializeConversations() async {
    final failureOrConversations = await _repository.getConversations();
    emit(state.copyWith(
      failureOrConversations: Some(failureOrConversations),
    ));
  }

  void _watchConversations() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _repository.watchConversations().listen(
      (failureOrConversations) {
        emit(state.copyWith(
          failureOrConversations: Some(failureOrConversations),
        ));
      },
    );
  }

  void selectConversation(String conversationId) {
    emit(state.copyWith(
      selectedConversationId: Some(conversationId),
      failureOrMessages: none(),
    ));
    _watchMessages(conversationId);
  }

  void _watchMessages(String conversationId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.watchMessages(conversationId).listen(
      (failureOrMessages) {
        emit(state.copyWith(
          failureOrMessages: Some(failureOrMessages),
        ));
      },
    );
  }

  Future<void> sendMessage(String content) async {
    if (state.selectedConversationId.isNone()) return;

    final conversationId = state.selectedConversationId.toNullable()!;

    // Get the participant ID from the conversations list
    final participantId = state.failureOrConversations.fold(
      () => null,
      (failureOrConversations) => failureOrConversations.fold(
        (failure) => null,
        (conversations) => conversations
            .firstWhere((conv) => conv.id == conversationId)
            .participantId,
      ),
    );

    if (participantId == null) return;

    emit(state.copyWith(isSending: true));

    final message = ChatMessage(
      id: DateTime.now().toString(),
      senderId: 'currentUser',
      receiverId:
          participantId, // Use participant ID instead of conversation ID
      content: content,
      timestamp: DateTime.now(),
    );

    final result = await _repository.sendMessage(message);

    emit(state.copyWith(
      isSending: false,
      failureOrSuccess: Some(result),
    ));
  }

  Future<void> markMessageAsRead(String messageId) async {
    final result = await _repository.markMessageAsRead(messageId);
    emit(state.copyWith(failureOrSuccess: Some(result)));
  }

  Future<void> clearChatHistory(String conversationId) async {
    await _repository.clearChatHistory(conversationId);
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _repository.dispose();
    return super.close();
  }
}
