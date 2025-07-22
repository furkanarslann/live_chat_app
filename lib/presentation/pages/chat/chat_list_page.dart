import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/presentation/core/build_context_translate_ext.dart';
import '../../../application/chat/chat_cubit.dart';
import '../../../application/chat/chat_state.dart';
import '../../../domain/models/chat_conversation.dart';
import '../../core/app_theme.dart';

import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.tr.chats,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
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
                  //TODO(Furkan): Implement new chat
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              _buildFilterChips(context),
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return state.failureOrConversations.fold(
                      () => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      (failureOrConversations) => failureOrConversations.fold(
                        (failure) => Center(
                          child: Text(
                            context.tr.errorOccured,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                        (conversations) => conversations.isEmpty
                            ? _EmptyState()
                            : CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isWide ? 32 : 0,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          if (index == 0) {
                                            return _ArchivedButton(
                                              onTap: () {
                                                //TODO(Furkan): Implement archived
                                              },
                                            );
                                          }
                                          return _ConversationTile(
                                            conversation:
                                                conversations[index - 1],
                                            onTap: () {
                                              context
                                                  .read<ChatCubit>()
                                                  .selectConversation(
                                                      conversations[index - 1]
                                                          .id);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                    conversation: conversations[
                                                        index - 1],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        childCount: conversations.length + 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing['md']!,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: context.tr.all,
                  isSelected: true,
                  onTap: () {},
                ),
                SizedBox(width: AppTheme.spacing['sm']),
                _FilterChip(
                  label: context.tr.unread,
                  isSelected: false,
                  onTap: () {},
                ),
                SizedBox(width: AppTheme.spacing['sm']),
                _FilterChip(
                  label: context.tr.favorites,
                  isSelected: false,
                  onTap: () {},
                ),
                SizedBox(width: AppTheme.spacing['sm']),
                _FilterChip(
                  label: context.tr.groups,
                  isSelected: false,
                  onTap: () {},
                ),
                SizedBox(width: AppTheme.spacing['sm']),
                _FilterChip(
                  icon: Icons.add,
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
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
            : theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
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

  const _ArchivedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing['md']!,
        vertical: AppTheme.spacing['sm']!,
      ),
      child: Material(
        color: theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing['md']!,
              vertical: AppTheme.spacing['sm']!,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing['sm']!),
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
                SizedBox(width: AppTheme.spacing['md']),
                Expanded(
                  child: Text(
                    context.tr.archived,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing['lg']!),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing['lg']!),
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
            SizedBox(height: AppTheme.spacing['lg']),
            Text(
              context.tr.noConversations,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppTheme.spacing['sm']),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing['md']!,
          vertical: AppTheme.spacing['sm']!,
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
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          NetworkImage(conversation.participantAvatar),
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
                          color: AppTheme.statusColors['online'],
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
            SizedBox(width: AppTheme.spacing['md']),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                  SizedBox(height: AppTheme.spacing['xxs']),
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
                          margin: EdgeInsets.only(
                            left: AppTheme.spacing['sm']!,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing['xs']! + 2,
                            vertical: AppTheme.spacing['xxs']!,
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
