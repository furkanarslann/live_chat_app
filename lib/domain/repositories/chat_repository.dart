import 'package:dartz/dartz.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../core/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversation>>> getConversations();
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, Unit>> sendMessage(ChatMessage message);
  Future<Either<Failure, Unit>> markMessageAsRead(String messageId);
  Stream<Either<Failure, List<ChatMessage>>> watchMessages(
    String conversationId,
  );
  Stream<Either<Failure, List<ChatConversation>>> watchConversations();

  // Auto message simulation methods
  void startAutoMessages();
  void stopAutoMessages();
  void dispose();
}
