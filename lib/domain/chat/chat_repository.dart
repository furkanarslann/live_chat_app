import 'package:dartz/dartz.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import '../core/failures.dart';
import 'chat_conversation.dart';
import 'chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversation>>> getConversations();
  Stream<Either<Failure, List<ChatConversation>>> watchConversations();
  Future<Either<Failure, Unit>> deleteConversation(String conversationId);
  Future<Map<String, User>> getConversationParticipants(
    List<String> participantIds,
  );
  Future<Either<Failure, Unit>> clearConversationChatHistory(
    String conversationId,
  );

  Stream<Either<Failure, List<ChatMessage>>> watchMessages(
    String conversationId,
  );
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, Unit>> sendMessage({
    required String content,
    required String participantId,
    required String conversationId,
  });
  Future<Either<Failure, Unit>> markMessageAsRead(String messageId);

  /// Mark multiple messages as read (only for receiver)
  Future<Either<Failure, Unit>> markMessagesAsRead(List<String> messageIds);

  /// Mark all unread messages in a conversation as read (only for receiver)
  Future<Either<Failure, Unit>> markConversationMessagesAsRead(
    String conversationId,
  );

  /// Get unread message counts for all conversations where current user is receiver
  Future<Map<String, int>> getUnreadMessagesCount();
}
