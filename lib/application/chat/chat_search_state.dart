import 'package:equatable/equatable.dart';
import 'package:live_chat_app/domain/models/chat_message.dart';

class ChatSearchState extends Equatable {
  final String searchQuery;
  final bool isSearching;
  final List<ChatMessage> allMessages;
  final List<ChatMessage> searchResults;

  const ChatSearchState({
    this.searchQuery = '',
    this.isSearching = false,
    this.allMessages = const [],
    this.searchResults = const [],
  });

  @override
  List<Object?> get props => [
        searchQuery,
        isSearching,
        allMessages,
        searchResults,
      ];

  bool get hasSearchQuery => searchQuery.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;

  ChatSearchState copyWith({
    String? searchQuery,
    bool? isSearching,
    List<ChatMessage>? allMessages,
    List<ChatMessage>? searchResults,
  }) {
    return ChatSearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      allMessages: allMessages ?? this.allMessages,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}
