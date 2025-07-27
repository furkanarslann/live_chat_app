import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/chat/chat_search_cubit.dart';
import 'package:live_chat_app/application/chat/chat_search_state.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/domain/models/chat_conversation.dart';
import 'package:live_chat_app/domain/models/chat_message.dart';
import 'package:live_chat_app/domain/models/user.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_auth_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'chat_page.dart';

class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    context.read<ChatSearchCubit>().searchQueryChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        return BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final currentUser = userState.user;
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: context.colors.background,
                title: Text(
                  context.tr.searchResults,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Column(
                children: [
                  _SearchBar(
                    controller: _searchController,
                    focusNode: _focusNode,
                  ),
                  Expanded(
                    child: BlocBuilder<ChatSearchCubit, ChatSearchState>(
                      builder: (context, searchState) {
                        if (searchState.searchQuery.isEmpty) {
                          return _SearchEmptyState();
                        }

                        if (searchState.isSearching) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final results = _performSearch(
                          searchState.searchQuery,
                          chatState,
                          currentUser,
                        );

                        if (results.isEmpty) {
                          return _NoSearchResultsState(
                            query: searchState.searchQuery,
                          );
                        }

                        return _SearchResultsList(
                          results: results,
                          currentUser: currentUser,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<SearchResult> _performSearch(
    String query,
    ChatState chatState,
    User currentUser,
  ) {
    final results = <SearchResult>[];
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
          results.add(SearchResult.conversation(conversation, participant));
        }
        
        // Search in last message of conversation
        if (conversation.lastMessage != null) {
          final content = conversation.lastMessage!.content.toLowerCase();
          if (content.contains(lowerQuery)) {
            results.add(SearchResult.message(conversation.lastMessage!, conversation, participant));
          }
        }
      }
    }

    // Search in current conversation messages (if any conversation is selected)
    final selectedConversationId = chatState.selectedConversationIdOpt.toNullable();
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
              results.add(SearchResult.message(message, conversation, participant));
            }
          }
        }
      }
    }

    // Remove duplicates and sort by relevance
    final uniqueResults = <String, SearchResult>{};
    for (final result in results) {
      final key = result.conversation.id;
      if (!uniqueResults.containsKey(key) || result.type == SearchResultType.message) {
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: context.tr.searchChats,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    focusNode.requestFocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              context.tr.searchChats,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Search through your conversations and messages',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultsState extends StatelessWidget {
  final String query;

  const _NoSearchResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              context.tr.noSearchResults,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'No results found for "$query"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final List<SearchResult> results;
  final User currentUser;

  const _SearchResultsList({
    required this.results,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultTile(
          result: result,
          currentUser: currentUser,
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final User currentUser;

  const _SearchResultTile({
    required this.result,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        leading: UserAvatar(
          imageUrl: result.participant.displayPhotoUrl,
        ),
        title: Text(
          result.participant.fullName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.type == SearchResultType.message && result.message != null)
              Text(
                result.message!.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            const SizedBox(height: 4),
            Text(
              result.type == SearchResultType.conversation
                  ? 'Conversation'
                  : 'Message',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        trailing: Icon(
          result.type == SearchResultType.conversation
              ? Icons.chat_bubble_outline
              : Icons.message_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(conversation: result.conversation),
            ),
          );
        },
      ),
    );
  }
}

enum SearchResultType { conversation, message }

class SearchResult {
  final SearchResultType type;
  final ChatConversation conversation;
  final User participant;
  final ChatMessage? message;

  SearchResult.conversation(this.conversation, this.participant)
      : type = SearchResultType.conversation,
        message = null;

  SearchResult.message(this.message, this.conversation, this.participant)
      : type = SearchResultType.message;
} 