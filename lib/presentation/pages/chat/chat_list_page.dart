import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';
import '../../../application/chat/chat_cubit.dart';
import '../../../application/chat/chat_state.dart';
import '../../../domain/models/chat_conversation.dart';
import '../../core/app_theme.dart';
import 'chat_page.dart';
import 'package:live_chat_app/presentation/pages/chat/create_new_chat_bottom_sheet.dart';
import 'package:live_chat_app/application/chat/create_chat_cubit.dart';
import 'package:live_chat_app/setup_dependencies.dart';

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
      builder: (context) => BlocProvider(
        create: (context) => getIt<CreateChatCubit>(),
        child: const CreateNewChatBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: () {
              _showCreateNewChatSheet();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const _FilterChips(),
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return state.failureOrConversationsOpt.fold(
                  () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  (failureOrConversations) => failureOrConversations.fold(
                    (failure) => Center(
                      child: Text(
                        context.tr.errorOccured,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                    (conversations) => conversations.isEmpty
                        ? _ChatListEmptyContent()
                        : _ChatListFilledContent(conversations),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListFilledContent extends StatelessWidget {
  final List<ChatConversation> conversations;
  const _ChatListFilledContent(this.conversations);

  List<ChatConversation> get _sortedConversations {
    final nonArchived =
        conversations.where((conv) => !conv.isArchived).toList();
    nonArchived.sort((a, b) {
      // First sort by pinned status
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1; // Pinned conversations go first
      }
      // Then sort by date within each group (pinned and unpinned)
      final aTime = a.lastMessage?.timestamp ?? DateTime(0);
      final bTime = b.lastMessage?.timestamp ?? DateTime(0);
      return bTime.compareTo(aTime); // Newest first
    });
    return nonArchived;
  }

  List<ChatConversation> get _archivedConversations {
    return conversations.where((conv) => conv.isArchived).toList()
      ..sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? DateTime(0);
        final bTime = b.lastMessage?.timestamp ?? DateTime(0);
        return bTime.compareTo(aTime); // Newest first
      });
  }

  @override
  Widget build(BuildContext context) {
    final sortedConversations = _sortedConversations;
    final archivedConversations = _archivedConversations;
    final hasArchivedConversations = archivedConversations.isNotEmpty;

    return CustomScrollView(
      slivers: [
        if (hasArchivedConversations)
          SliverToBoxAdapter(
            child: _ArchivedButton(
              count: archivedConversations.length,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchivedConversationsPage(
                      conversations: archivedConversations,
                    ),
                  ),
                );
              },
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final current = sortedConversations[index];
              return _ConversationTile(
                conversation: current,
                onTap: () {
                  context.read<ChatCubit>().selectConversation(current.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        conversation: current,
                      ),
                    ),
                  );
                },
              );
            },
            childCount: sortedConversations.length,
          ),
        ),
      ],
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
            horizontal: Spacing.sm,
          ),
          child: Row(
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
              const SizedBox(width: Spacing.sm),
              _FilterChip(
                icon: Icons.add,
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
  final List<ChatConversation> conversations;

  const ArchivedConversationsPage({
    super.key,
    required this.conversations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.archived),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final archivedConversations = state.archivedConversations;

          if (archivedConversations.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            itemCount: archivedConversations.length,
            itemBuilder: (context, index) {
              final conversation = archivedConversations[index];
              return _ConversationTile(
                conversation: conversation,
                onTap: () {
                  context.read<ChatCubit>().selectConversation(conversation.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(conversation: conversation),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(conversation.id),
      // Start action pane (right to left swipe)
      startActionPane: conversation.isArchived
          ? ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    context
                        .read<ChatCubit>()
                        .toggleArchiveConversation(conversation.id);
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.unarchive,
                  label: context.tr.unarchive,
                ),
              ],
            )
          : ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    context.read<ChatCubit>().togglePin(conversation.id);
                  },
                  backgroundColor:
                      conversation.isPinned ? Colors.orange : Colors.blue,
                  foregroundColor: Colors.white,
                  icon: conversation.isPinned
                      ? Icons.push_pin_outlined
                      : Icons.push_pin,
                  label:
                      conversation.isPinned ? context.tr.unpin : context.tr.pin,
                ),
              ],
            ),
      // End action pane (left to right swipe)
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            context.read<ChatCubit>().deleteConversation(conversation.id);
          },
        ),
        children: [
          if (!conversation.isArchived)
            SlidableAction(
              onPressed: (_) {
                context
                    .read<ChatCubit>()
                    .toggleArchiveConversation(conversation.id);
              },
              backgroundColor: const Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: context.tr.archived,
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
        onTap: onTap,
      ),
    );
  }
}

class _ConversationTileContent extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const _ConversationTileContent({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Hero(
              tag: 'avatar_${conversation.id}',
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      imageUrl: conversation.participantAvatar,
                      radius: 28,
                    ),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (conversation.isPinned)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.push_pin,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(
                          context,
                          conversation.lastMessage?.timestamp,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: conversation.unreadCount > 0
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : null,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Row(
                    children: [
                      if (conversation.lastMessage?.senderId == 'currentUser')
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            conversation.lastMessage!.isRead
                                ? Icons.done_all
                                : Icons.done,
                            size: 16,
                            color: conversation.lastMessage!.isRead
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: conversation.unreadCount > 0
                                ? colorScheme.onSurface.withValues(alpha: 0.9)
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : null,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(
                            left: Spacing.sm,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs + 2,
                            vertical: Spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 20,
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return context.tr.yesterday;
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
