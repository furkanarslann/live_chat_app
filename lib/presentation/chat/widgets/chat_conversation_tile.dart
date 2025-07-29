import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/domain/chat/chat_conversation.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/router/app_router.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';
import 'chat_message_read_status.dart';
import 'conversation_tile_shimmer.dart';

class ChatConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final User currentUser;

  const ChatConversationTile({
    super.key,
    required this.conversation,
    required this.currentUser,
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
                currentUser.chatPreferences.isPinned(conversation.id)
                    ? Colors.orange
                    : Colors.blue,
            foregroundColor: Colors.white,
            icon: currentUser.chatPreferences.isPinned(conversation.id)
                ? Icons.push_pin_outlined
                : Icons.push_pin,
            label: currentUser.chatPreferences.isPinned(conversation.id)
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
                currentUser.chatPreferences.isArchived(conversation.id)
                    ? Colors.orange
                    : const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: currentUser.chatPreferences.isArchived(conversation.id)
                ? Icons.unarchive
                : Icons.archive,
            label: currentUser.chatPreferences.isArchived(conversation.id)
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
      child: ChatConversationTileContent(
        conversation: conversation,
        currentUser: currentUser,
        onTap: () => context.push(AppRouter.chat, extra: conversation),
      ),
    );
  }
}

class ChatConversationTileContent extends StatelessWidget {
  final ChatConversation conversation;
  final User currentUser;
  final VoidCallback onTap;

  const ChatConversationTileContent({
    super.key,
    required this.conversation,
    required this.currentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPinned = currentUser.chatPreferences.isPinned(conversation.id);

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, chatState) {
        final participantId = conversation.getParticipantId(currentUser);
        final participant = chatState.findParticipant(participantId);
        if (participant == null) return const ConversationTileShimmer();

        final unreadCount = chatState.getUnreadCount(conversation.id);
        final lastMessage = chatState.getLastMessage(conversation.id);
        final isLastMessageSentByMe = lastMessage?.senderId == currentUser.id;

        return ListTile(
          leading: UserAvatar(
            imageUrl: participant.displayPhotoUrl,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  participant.fullName,
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
          subtitle: lastMessage != null
              ? Row(
                  children: [
                    if (isLastMessageSentByMe) ...[
                      ChatMessageReadStatus(
                        isRead: lastMessage.isRead,
                        isMe: isLastMessageSentByMe,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      lastMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                unreadCount > 0 ? FontWeight.bold : null,
                          ),
                    ),
                  ],
                )
              : null,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lastMessage != null)
                Text(
                  _formatTime(lastMessage.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        );
      },
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
