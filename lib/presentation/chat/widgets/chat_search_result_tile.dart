import 'package:flutter/material.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/domain/chat/chat_search_result.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';
import 'package:live_chat_app/presentation/chat/chat_page.dart';

class ChatSearchResultTile extends StatelessWidget {
  final ChatSearchResult result;
  final User currentUser;

  const ChatSearchResultTile({
    super.key,
    required this.result,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.surface,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        leading: UserAvatar(
          imageUrl: result.participant.displayPhotoUrl,
        ),
        title: Text(
          result.participant.fullName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.type == ChatSearchResultType.message &&
                result.message != null)
              Text(
                result.message!.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            const SizedBox(height: 4),
            Text(
              result.type == ChatSearchResultType.conversation
                  ? context.tr.conversationType
                  : context.tr.messageType,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        trailing: Icon(
          result.type == ChatSearchResultType.conversation
              ? Icons.chat_bubble_outline
              : Icons.message_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(conversation: result.conversation),
            ),
          );
        },
      ),
    );
  }
}
