import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

/// Widget to display message read status with appropriate icons and colors
class ChatMessageReadStatus extends StatelessWidget {
  final bool isRead;
  final bool isMe;
  final bool isPending;
  final Color sentColor;

  const ChatMessageReadStatus({
    super.key,
    required this.isRead,
    required this.isMe,
    this.isPending = false,
    this.sentColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    // Only show read status for messages sent by current user
    if (!isMe) return const SizedBox.shrink();

    return Tooltip(
      message: _getStatusTooltip(context),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _buildStatusIcon(context),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (isPending) {
      // Pending/sending state
      return SizedBox(
        key: const ValueKey('pending'),
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    // Sent or read state
    return Icon(
      isRead ? Icons.done_all : Icons.done,
      key: ValueKey(isRead ? 'read' : 'sent'),
      size: 14,
      color: _getReadStatusColor(context, isRead),
    );
  }

  Color _getReadStatusColor(BuildContext context, bool isRead) {
    if (isRead) {
      return Colors.lightBlueAccent;
    } else {
      return sentColor;
    }
  }

  String _getStatusTooltip(BuildContext context) {
    if (isPending) {
      return context.tr.sending;
    } else if (isRead) {
      return context.tr.read;
    } else {
      return context.tr.sent;
    }
  }
} 