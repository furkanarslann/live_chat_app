import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import '../../../application/auth/user_cubit.dart';
import '../../../application/chat/chat_cubit.dart';
import '../../../application/chat/chat_state.dart';
import '../../../application/chat/create_chat_cubit.dart';
import '../../../domain/models/chat_conversation.dart';
import '../../../domain/models/user.dart';
import '../../core/app_theme.dart';
import '../../core/extensions/build_context_translate_ext.dart';
import '../../core/widgets/user_avatar.dart';
import 'chat_page.dart';
import 'create_new_chat_bottom_sheet.dart';
import '../../../setup_dependencies.dart';

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
                const _FilterChips(),
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

  List<ChatConversation> _filterConversations(
    List<ChatConversation> conversations,
  ) {
    final nonArchived = conversations
        .where((conv) => !currentUser.chatPreferences.isArchivedBy(conv.id))
        .toList();

    nonArchived.sort((a, b) {
      final aPinned = currentUser.chatPreferences.isPinnedBy(a.id);
      final bPinned = currentUser.chatPreferences.isPinnedBy(b.id);
      if (aPinned != bPinned) return aPinned ? -1 : 1;

      final aTime = a.lastMessage?.timestamp ?? a.createdAt ?? DateTime(0);
      final bTime = b.lastMessage?.timestamp ?? b.createdAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    return nonArchived;
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
              if (conversations.isEmpty) return _ChatListEmptyContent();

              final filteredConversations = _filterConversations(conversations);
              final archivedCount =
                  conversations.length - filteredConversations.length;

              return CustomScrollView(
                slivers: [
                  if (archivedCount > 0)
                    SliverToBoxAdapter(
                      child: _ArchivedButton(
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
                        final conversation = filteredConversations[index];
                        return _ConversationTile(
                          conversation: conversation,
                          currentUser: currentUser,
                        );
                      },
                      childCount: filteredConversations.length,
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _FilterChip(
                label: context.tr.all,
                isSelected: true,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
              const SizedBox(width: Spacing.sm),
              _FilterChip(
                label: context.tr.unread,
                isSelected: false,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
              const SizedBox(width: Spacing.sm),
              _FilterChip(
                label: context.tr.favorites,
                isSelected: false,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
              const SizedBox(width: Spacing.sm),
              _FilterChip(
                label: context.tr.groups,
                isSelected: false,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer
            : theme.cardColor.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 68,
              minHeight: 36,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 16 : 12,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      semanticLabel: 'Add filter',
                    )
                  : Text(
                      label!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchivedButton extends StatelessWidget {
  final VoidCallback onTap;
  final int count;

  const _ArchivedButton({
    required this.onTap,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(Spacing.sm),
      child: Material(
        color: theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.archive_outlined,
                    color: theme.colorScheme.primary,
                    semanticLabel: context.tr.archived,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.archived,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count ${context.tr.conversations}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
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
                    currentUser.chatPreferences.isArchivedBy(conversation.id))
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
                        return _ConversationTile(
                          conversation: conversation,
                          currentUser: currentUser,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return ChatPage(conversation: conversation);
                                },
                              ),
                            );
                          },
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

class _ChatListEmptyContent extends StatelessWidget {
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
                Icons.chat_bubble_outline,
                size: 48,
                color: theme.colorScheme.primary,
                semanticLabel: context.tr.noConversations,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              context.tr.noConversations,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              context.tr.startChatting,
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

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final User currentUser;
  final VoidCallback? onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(conversation.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              context.read<UserCubit>().togglePinConversation(conversation.id);
            },
            backgroundColor:
                currentUser.chatPreferences.isPinnedBy(conversation.id)
                    ? Colors.orange
                    : Colors.blue,
            foregroundColor: Colors.white,
            icon: currentUser.chatPreferences.isPinnedBy(conversation.id)
                ? Icons.push_pin_outlined
                : Icons.push_pin,
            label: currentUser.chatPreferences.isPinnedBy(conversation.id)
                ? context.tr.unpin
                : context.tr.pin,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              context
                  .read<UserCubit>()
                  .toggleArchiveConversation(conversation.id);
            },
            backgroundColor:
                currentUser.chatPreferences.isArchivedBy(conversation.id)
                    ? Colors.orange
                    : const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: currentUser.chatPreferences.isArchivedBy(conversation.id)
                ? Icons.unarchive
                : Icons.archive,
            label: currentUser.chatPreferences.isArchivedBy(conversation.id)
                ? context.tr.unarchive
                : context.tr.archived,
          ),
          SlidableAction(
            onPressed: (_) {
              context.read<ChatCubit>().deleteConversation(conversation.id);
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: context.tr.delete,
          ),
        ],
      ),
      child: _ConversationTileContent(
        conversation: conversation,
        currentUser: currentUser,
        onTap: onTap ??
            () {
              context.read<ChatCubit>().selectConversation(conversation.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(conversation: conversation),
                ),
              );
            },
      ),
    );
  }
}

class _ConversationTileContent extends StatelessWidget {
  final ChatConversation conversation;
  final User currentUser;
  final VoidCallback onTap;

  const _ConversationTileContent({
    required this.conversation,
    required this.currentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPinned = currentUser.chatPreferences.isPinnedBy(conversation.id);
    final unreadCount =
        currentUser.chatPreferences.getUnreadCount(conversation.id);

    return ListTile(
      leading: UserAvatar(
        imageUrl: conversation.participantAvatar,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.participantName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: unreadCount > 0 ? FontWeight.bold : null,
                  ),
            ),
          ),
          if (isPinned)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.push_pin,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              conversation.lastMessage!.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: unreadCount > 0 ? FontWeight.bold : null,
                  ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessage != null)
            Text(
              _formatTime(conversation.lastMessage!.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
        ],
      ),
      onTap: onTap,
      onLongPress: () => _showConversationOptions(context),
    );
  }

  void _showConversationOptions(BuildContext context) {
    final isPinned = currentUser.chatPreferences.isPinnedBy(conversation.id);
    final isArchived =
        currentUser.chatPreferences.isArchivedBy(conversation.id);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                isPinned ? context.tr.unpin : context.tr.pin,
              ),
              onTap: () {
                context
                    .read<UserCubit>()
                    .togglePinConversation(conversation.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                isArchived ? Icons.unarchive : Icons.archive,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                isArchived ? context.tr.unarchive : context.tr.archived,
              ),
              onTap: () {
                context
                    .read<UserCubit>()
                    .toggleArchiveConversation(conversation.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                context.tr.delete,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr.delete),
        content: Text(
            '${context.tr.delete} ${context.tr.conversations.toLowerCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().deleteConversation(conversation.id);
              Navigator.pop(context);
            },
            child: Text(
              context.tr.delete,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${time.day}/${time.month}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
