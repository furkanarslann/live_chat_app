import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:live_chat_app/domain/chat/chat_message.dart';
import 'package:live_chat_app/domain/chat/chat_conversation.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/domain/chat/chat_search_result.dart';
import 'chat_search_state.dart';

@injectable
class ChatSearchCubit extends Cubit<ChatSearchState> {
  ChatSearchCubit() : super(const ChatSearchState());

  void initialize(List<ChatMessage> allMessages) {
    emit(state.copyWith(allMessages: allMessages));
  }

  void searchQueryChanged(String query) {
    emit(state.copyWith(
      searchQuery: query,
      isSearching: true,
    ));

    // Simulating search delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (state.searchQuery == query) {
        emit(state.copyWith(isSearching: false));
      }
    });
  }

  List<ChatSearchResult> performSearch(
    String query,
    ChatState chatState,
    User currentUser,
  ) {
    if (query.trim().isEmpty) return [];

    final results = <ChatSearchResult>[];
    final lowerQuery = query.toLowerCase();

    // Search in conversations
    final conversations = chatState.failureOrConversationsOpt.fold(
      () => <ChatConversation>[],
      (failureOrConversations) => failureOrConversations.fold(
        (failure) => <ChatConversation>[],
        (conversations) => conversations,
      ),
    );

    for (final conversation in conversations) {
      final participantId = conversation.getParticipantId(currentUser);
      final participant = chatState.findParticipant(participantId);

      if (participant != null) {
        final fullName = participant.fullName.toLowerCase();
        final firstName = participant.firstName.toLowerCase();
        final lastName = participant.lastName.toLowerCase();

        if (fullName.contains(lowerQuery) ||
            firstName.contains(lowerQuery) ||
            lastName.contains(lowerQuery)) {
          results.add(ChatSearchResult.conversation(conversation, participant));
        }

        // Search in last message of conversation
        if (conversation.lastMessage != null) {
          final content = conversation.lastMessage!.content.toLowerCase();
          if (content.contains(lowerQuery)) {
            results.add(ChatSearchResult.message(
                conversation.lastMessage!, conversation, participant));
          }
        }
      }
    }

    // Search in current conversation messages (if any conversation is selected)
    final selectedConversationId =
        chatState.selectedConversationIdOpt.toNullable();
    if (selectedConversationId != null) {
      final messages = chatState.messagesOrEmpty;
      final conversation = conversations.firstWhere(
        (conv) => conv.id == selectedConversationId,
        orElse: () => const ChatConversation(
          id: '',
          participants: [],
        ),
      );

      if (conversation.id.isNotEmpty) {
        final participantId = conversation.getParticipantId(currentUser);
        final participant = chatState.findParticipant(participantId);

        if (participant != null) {
          for (final message in messages) {
            final content = message.content.toLowerCase();
            if (content.contains(lowerQuery)) {
              results.add(
                  ChatSearchResult.message(message, conversation, participant));
            }
          }
        }
      }
    }

    // Remove duplicates and sort by relevance
    final uniqueResults = <String, ChatSearchResult>{};
    for (final result in results) {
      final key = result.conversation.id;
      if (!uniqueResults.containsKey(key) ||
          result.type == ChatSearchResultType.message) {
        uniqueResults[key] = result;
      }
    }

    return uniqueResults.values.toList()
      ..sort((a, b) {
        final aTime = a.conversation.lastMessage?.timestamp ?? DateTime(1900);
        final bTime = b.conversation.lastMessage?.timestamp ?? DateTime(1900);
        return bTime.compareTo(aTime); // Most recent first
      });
  }
}
