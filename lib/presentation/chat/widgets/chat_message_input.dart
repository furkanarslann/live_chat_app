import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

class ChatMessageInput extends StatefulWidget {
  final String conversationId;

  const ChatMessageInput({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                  widget.conversationId,
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
