import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/chat/chat_cubit.dart';
import '../../../application/chat/chat_state.dart';
import '../../../domain/models/chat_conversation.dart';
import '../../../domain/models/chat_message.dart';

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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.conversation.participantAvatar),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.participantName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.conversation.isOnline)
                  Text(
                    'Online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              //TODO(Furkan): Implement chat options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.failureOrMessages.isSome()) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              builder: (context, state) {
                return state.failureOrMessages.fold(
                  () => const Center(child: CircularProgressIndicator()),
                  (failureOrMessages) => failureOrMessages.fold(
                    (failure) => Center(
                      child: Text(
                        'Error: ${failure.message}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                    (messages) => messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == 'currentUser';
                              final showAvatar = index == 0 ||
                                  messages[index - 1].senderId !=
                                      message.senderId;

                              return _MessageBubble(
                                message: message,
                                isMe: isMe,
                                showAvatar: showAvatar,
                                participantAvatar:
                                    widget.conversation.participantAvatar,
                              );
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
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
                            context
                                .read<ChatCubit>()
                                .sendMessage(_messageController.text.trim());
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String participantAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.participantAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(participantAvatar),
            ),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 40),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? colorScheme.primary : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      Radius.circular(isMe || !showAvatar ? 20 : 5),
                  bottomRight:
                      Radius.circular(!isMe || !showAvatar ? 20 : 5),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isMe
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
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
                              ? colorScheme.onPrimary.withOpacity(0.7)
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? Colors.blue
                              : colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Text(
                'Me',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
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