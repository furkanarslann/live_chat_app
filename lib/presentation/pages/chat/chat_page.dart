import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_auth_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import '../../../application/chat/chat_cubit.dart';
import '../../../application/chat/chat_state.dart';
import '../../../domain/models/chat_conversation.dart';
import '../../../domain/models/chat_message.dart';
import '../../core/extensions/build_context_translate_ext.dart';
import '../../core/widgets/user_avatar.dart';
import '../../core/widgets/glassy_snackbar.dart';
import 'participant_profile_page.dart';

class ChatPage extends StatefulWidget {
  final ChatConversation conversation;

  const ChatPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatCubit = context.read<ChatCubit>();
      chatCubit.selectConversation(widget.conversation.id);

      final participantId = widget.conversation.getParticipantId(
        context.currentUser,
      );
      await chatCubit.loadSingleParticipant(participantId);

      chatCubit.watchSelectedConversationMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final participant = state.findParticipant(
          widget.conversation.getParticipantId(context.currentUser),
        );

        if (participant == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParticipantProfilePage(
                          participant: participant,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      UserAvatar(
                        imageUrl: participant.displayPhotoUrl,
                        radius: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant.fullName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          // TODO(Furkan): Show online status from user model
                          if (true)
                            Text(
                              context.tr.online,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.green,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          body: BlocListener<ChatCubit, ChatState>(
            listenWhen: (previous, current) =>
                previous.failOrSendSuccessOpt != current.failOrSendSuccessOpt,
            listener: (context, state) {
              state.failOrSendSuccessOpt.fold(
                () {},
                (failureOrSuccess) => failureOrSuccess.fold(
                  (failure) {
                    // Show error message
                    GlassySnackBar.show(
                      context,
                      message: context.tr.errorOccured,
                      type: GlassySnackBarType.failure,
                    );
                    // Clear error state after showing message
                    context.read<ChatCubit>().clearErrorState();
                  },
                  (success) {
                    // Message sent successfully - no need to show anything
                    // Clear success state
                    context.read<ChatCubit>().clearErrorState();
                  },
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      return state.failureOrMessagesOpt.fold(
                        () => const Center(child: CircularProgressIndicator()),
                        (failureOrMessages) => failureOrMessages.fold(
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
                          (messages) => messages.isEmpty
                              ? const _EmptyChatContent()
                              : _FilledChatContent(
                                  conversation: widget.conversation,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {
                //TODO(Furkan): Implement emoji picker
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: context.tr.typeMessage,
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return IconButton(
                  icon: state.isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  onPressed: state.isSending
                      ? null
                      : () {
                          if (_messageController.text.trim().isNotEmpty) {
                            context.read<ChatCubit>().sendMessage(
                                  _messageController.text.trim(),
                                  widget.conversation
                                      .getParticipantId(context.currentUser),
                                );
                            _messageController.clear();
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledChatContent extends StatefulWidget {
  const _FilledChatContent({required this.conversation});

  final ChatConversation conversation;

  @override
  State<_FilledChatContent> createState() => _FilledChatContentState();
}

class _FilledChatContentState extends State<_FilledChatContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(context, animated: false);
      // Mark messages as read when conversation is clicked
      context
          .read<ChatCubit>()
          .markMessagesAsReadOnView(widget.conversation.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom(context, {bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (!animated) return _scrollController.jumpTo(maxScrollExtent);

    _scrollController.animateTo(
      maxScrollExtent + 50,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Mark new unread messages as read when they arrive
  void _markNewMessagesAsRead(BuildContext context, ChatState state) {
    final messages = state.messagesOrEmpty;
    if (messages.isEmpty) return;

    final currentUserId = context.userId;
    final unreadMessageIds = <String>[];

    // Find unread messages where current user is the receiver
    for (final message in messages) {
      if (message.receiverId == currentUserId && !message.isRead) {
        unreadMessageIds.add(message.id);
      }
    }

    // Mark unread messages as read
    if (unreadMessageIds.isNotEmpty) {
      context.read<ChatCubit>().markMessagesAsRead(unreadMessageIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        return previous.messagesOrEmpty.length !=
            current.messagesOrEmpty.length;
      },
      listener: (context, state) {
        if (state.messagesOrEmpty.isEmpty) return;

        // Mark new messages as read when they arrive
        _markNewMessagesAsRead(context, state);

        _scrollToBottom(context);
      },
      builder: (context, state) {
        final messages = state.messagesOrEmpty;
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == context.userId;
            final isLastMessage = index == messages.length - 1;
            final isPending = isMe && isLastMessage && state.isSending;

            final participantId =
                widget.conversation.getParticipantId(context.currentUser);
            final participant = state.findParticipant(participantId)!;
            final participantAvatar = participant.displayPhotoUrl;

            return _MessageBubble(
              message: message,
              isMe: isMe,
              avatar: participantAvatar,
              isPending: isPending,
            );
          },
        );
      },
    );
  }
}

class _EmptyChatContent extends StatelessWidget {
  const _EmptyChatContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr.noMessagesTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr.noMessagesSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String avatar;
  final bool isPending;

  const _MessageBubble({
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
                        _MessageReadStatus(
                          isRead: message.isRead,
                          isMe: isMe,
                          isPending: isPending,
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

/// Widget to display message read status with appropriate icons and colors
class _MessageReadStatus extends StatelessWidget {
  final bool isRead;
  final bool isMe;
  final bool isPending;

  const _MessageReadStatus({
    required this.isRead,
    required this.isMe,
    this.isPending = false,
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
    final colorScheme = Theme.of(context).colorScheme;

    if (isRead) {
      return Colors.lightBlueAccent;
    } else {
      // Sent but not read: Gray color
      return colorScheme.onPrimary.withValues(alpha: 0.7);
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
