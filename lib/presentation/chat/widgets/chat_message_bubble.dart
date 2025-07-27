import 'package:flutter/material.dart';
import 'package:live_chat_app/domain/chat/chat_message.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';
import 'chat_message_read_status.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String avatar;
  final bool isPending;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.avatar,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarExist = avatar.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            UserAvatar(
              imageUrl: avatar,
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? context.colors.primary : context.colors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe || !avatarExist ? 20 : 5),
                  bottomRight: Radius.circular(!isMe || !avatarExist ? 20 : 5),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isMe
                              ? colorScheme.onPrimary.withValues(alpha: 0.7)
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        ChatMessageReadStatus(
                          isRead: message.isRead,
                          isMe: isMe,
                          isPending: isPending,
                          sentColor: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe && avatarExist) ...[
            const SizedBox(width: 8),
            UserAvatar(
              imageUrl: avatar,
              radius: 16,
            ),
          ] else if (isMe) ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
} 