import 'package:live_chat_app/domain/chat/chat_conversation.dart';
import 'package:live_chat_app/domain/chat/chat_message.dart';
import 'package:live_chat_app/domain/auth/user.dart';

enum ChatSearchResultType { conversation, message }

class ChatSearchResult {
  final ChatSearchResultType type;
  final ChatConversation conversation;
  final User participant;
  final ChatMessage? message;

  ChatSearchResult.conversation(this.conversation, this.participant)
      : type = ChatSearchResultType.conversation,
        message = null;

  ChatSearchResult.message(this.message, this.conversation, this.participant)
      : type = ChatSearchResultType.message;
}
