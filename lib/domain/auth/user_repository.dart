import 'package:dartz/dartz.dart';
import '../core/failures.dart';
import 'user.dart';
import 'user_chat_preferences.dart';

abstract class UserRepository {
  Stream<Either<Failure, User>> watchCurrentUser();
  Future<Either<Failure, Unit>> updateChatPreferences(UserChatPreferences preferences);
  Future<Either<Failure, Unit>> togglePinConversation(String conversationId);
  Future<Either<Failure, Unit>> toggleArchiveConversation(String conversationId);
} 