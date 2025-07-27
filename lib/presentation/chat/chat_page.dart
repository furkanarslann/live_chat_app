import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_auth_ext.dart';
import '../../application/chat/chat_cubit.dart';
import '../../application/chat/chat_state.dart';
import '../../domain/chat/chat_conversation.dart';
import '../core/extensions/build_context_translate_ext.dart';
import '../core/widgets/user_avatar.dart';
import '../core/widgets/glassy_snackbar.dart';
import 'chat_participant_profile_page.dart';
import 'widgets/chat_empty_messages_content.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_message_input.dart';

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
                        builder: (_) => ChatParticipantProfilePage(
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
                  },
                  (_) {
                    // Message sent successfully - no need to show anything
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
                              ? const ChatEmptyMessagesContent()
                              : _FilledChatContent(
                                  conversation: widget.conversation,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                ChatMessageInput(
                  conversationId:
                      widget.conversation.getParticipantId(context.currentUser),
                ),
              ],
            ),
          ),
        );
      },
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

            return ChatMessageBubble(
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
