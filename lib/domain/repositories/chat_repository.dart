import 'package:dartz/dartz.dart';
import '../core/failures.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversation>>> getConversations();
  Stream<Either<Failure, List<ChatConversation>>> watchConversations();

  Stream<Either<Failure, List<ChatMessage>>> watchMessages(
    String conversationId,
  );
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, Unit>> sendMessage({
    required String content,
    required String participantId,
  });
  Future<Either<Failure, Unit>> markMessageAsRead(String messageId);

  Future<Either<Failure, Unit>> clearChatHistory(String conversationId);
  Future<Either<Failure, Unit>> deleteConversation(String conversationId);
}
