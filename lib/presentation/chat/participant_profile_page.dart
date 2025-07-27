import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_auth_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_dialog_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';

class ParticipantProfilePage extends StatelessWidget {
  final User participant;

  const ParticipantProfilePage({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr.profile,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24),
            _ProfileHeader(),
            SizedBox(height: 32),
            _ActionButtons(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final participant = context
        .findAncestorWidgetOfExactType<ParticipantProfilePage>()!
        .participant;

    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${participant.id}',
            child: UserAvatar(
              radius: 60,
              imageUrl: participant.displayPhotoUrl,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            participant.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // TODO(Furkan): Show online status from user model
          const _OnlineStatusIndicator(isOnline: true),
        ],
      ),
    );
  }
}

class _OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;

  const _OnlineStatusIndicator({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? context.tr.online : context.tr.offline,
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          context.tr.clearChatHistory,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.redAccent.withValues(alpha: 0.2),
          ),
        ),
        onTap: () => _showClearChatDialog(context),
      ),
    );
  }

  Future<void> _showClearChatDialog(BuildContext context) async {
    final participant = context
        .findAncestorWidgetOfExactType<ParticipantProfilePage>()!
        .participant;

    final shouldClear =
        await context.showClearChatDialog(participant.firstName);

    if (shouldClear == null || !shouldClear || !context.mounted) return;

    final userId = context.userId;
    final participantId = participant.id;
    final ids = [userId, participantId]..sort();
    final conversationId = ids.join('_');

    await context
        .read<ChatCubit>()
        .clearConversationChatHistory(conversationId);
  }
}
