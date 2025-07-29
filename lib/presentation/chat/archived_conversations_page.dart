import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/domain/chat/chat_conversation.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'widgets/chat_conversation_tile.dart';

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
                    currentUser.chatPreferences.isArchived(conversation.id))
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
                        return ChatConversationTile(
                          conversation: conversation,
                          currentUser: currentUser,
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
