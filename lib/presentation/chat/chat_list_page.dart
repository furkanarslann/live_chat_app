import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_auth_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import '../../application/auth/user_cubit.dart';
import '../../application/chat/chat_cubit.dart';
import '../../application/chat/chat_state.dart';
import '../../domain/auth/user.dart';
import '../../application/chat/create_chat_cubit.dart';
import '../../domain/chat/chat_conversation.dart';
import '../core/app_theme.dart';
import '../core/extensions/build_context_translate_ext.dart';
import 'widgets/chat_search_bar.dart';
import 'widgets/chat_filter_chips.dart';
import 'widgets/chat_archived_button.dart';
import 'widgets/chat_empty_content.dart';
import 'widgets/chat_conversation_tile.dart';
import 'create_new_chat_bottom_sheet.dart';
import '../../setup_dependencies.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  void _showCreateNewChatSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      builder: (_) => BlocProvider(
        create: (_) => getIt<CreateChatCubit>(),
        child: const CreateNewChatBottomSheet(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context
          .read<ChatCubit>()
          .loadParticipantsForConversations(currentUserId: context.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return state.userOpt.fold(
          () => Center(
            child: Text(
              context.tr.errorOccured,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
          (user) => Scaffold(
            appBar: AppBar(
              backgroundColor: context.colors.background,
              title: Text(
                context.tr.chats,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 26,
                  tooltip: context.tr.newChat,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: _showCreateNewChatSheet,
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ChatSearchBar(),
                const ChatFilterChips(),
                Expanded(child: _ChatListContent(currentUser: user)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatListContent extends StatelessWidget {
  final User currentUser;

  const _ChatListContent({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return state.failureOrConversationsOpt.fold(
          () => const Center(child: CircularProgressIndicator()),
          (failureOrConversations) => failureOrConversations.fold(
            (failure) => Center(
              child: Text(
                context.tr.errorOccured,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
            (conversations) {
              if (conversations.isEmpty) return const ChatEmptyContent();

              final visibleConversations = state.getNonArchivedConversations(
                currentUser,
              );

              final archivedCount = conversations.where((conversation) {
                return currentUser.chatPreferences
                    .isArchived(conversation.id);
              }).length;

              return CustomScrollView(
                slivers: [
                  if (archivedCount > 0)
                    SliverToBoxAdapter(
                      child: ChatArchivedButton(
                        count: archivedCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ArchivedConversationsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final conversation = visibleConversations[index];
                        return ChatConversationTile(
                          conversation: conversation,
                          currentUser: currentUser,
                        );
                      },
                      childCount: visibleConversations.length,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ArchivedConversationsPage extends StatelessWidget {
  const ArchivedConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        return BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final conversations = chatState.failureOrConversationsOpt.fold(
              () => <ChatConversation>[],
              (failureOrConversations) => failureOrConversations.fold(
                (failure) => <ChatConversation>[],
                (conversations) => conversations,
              ),
            );

            final currentUser = userState.user;
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final archivedConversations = conversations
                .where((conversation) =>
                    currentUser.chatPreferences.isArchived(conversation.id))
                .toList();

            return Scaffold(
              appBar: AppBar(
                title: Text(context.tr.archived),
              ),
              body: archivedConversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.archive_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: Spacing.md),
                          Text(
                            context.tr.noConversations,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: archivedConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = archivedConversations[index];
                        return ChatConversationTile(
                          conversation: conversation,
                          currentUser: currentUser,
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}
