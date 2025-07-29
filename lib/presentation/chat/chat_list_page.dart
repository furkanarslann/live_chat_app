import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import '../../application/auth/user_cubit.dart';
import '../../application/chat/chat_cubit.dart';
import '../../application/chat/chat_state.dart';
import '../../domain/auth/user.dart';
import '../../application/chat/create_chat_cubit.dart';
import '../core/extensions/build_context_translate_ext.dart';
import '../core/router/app_router.dart';
import 'widgets/chat_search_bar.dart';
import 'widgets/chat_filter_chips.dart';
import 'widgets/chat_archived_button.dart';
import 'widgets/chat_empty_content.dart';
import 'widgets/chat_conversation_tile.dart';
import 'create_new_chat_bottom_sheet.dart';
import '../../di/injection.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  void _showCreateNewChatSheet(BuildContext context) async {
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
                  onPressed: () => _showCreateNewChatSheet(context),
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

  Future<void> _refreshConversations(BuildContext context) async {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.initialize();
  }

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
                return currentUser.chatPreferences.isArchived(conversation.id);
              }).length;

              return RefreshIndicator(
                onRefresh: () => _refreshConversations(context),
                child: CustomScrollView(
                  slivers: [
                    if (archivedCount > 0)
                      SliverToBoxAdapter(
                        child: ChatArchivedButton(
                          count: archivedCount,
                          onTap: () {
                            context.go(AppRouter.archivedConversations);
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}
