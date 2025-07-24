import 'package:flutter/material.dart';
import 'package:live_chat_app/domain/models/chat_conversation.dart';

class ParticipantProfilePage extends StatelessWidget {
  final ChatConversation conversation;

  const ParticipantProfilePage({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
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
    final conversation = context
        .findAncestorWidgetOfExactType<ParticipantProfilePage>()!
        .conversation;

    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${conversation.participantId}',
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(conversation.participantAvatar),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            conversation.participantName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _OnlineStatusIndicator(isOnline: conversation.isOnline),
        ],
      ),
    );
  }
}

class _OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;

  const _OnlineStatusIndicator({
    required this.isOnline,
  });

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
            isOnline ? 'Online' : 'Offline',
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
        title: const Text(
          'Clear Chat History',
          style: TextStyle(
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
    final conversation = context
        .findAncestorWidgetOfExactType<ParticipantProfilePage>()!
        .conversation;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: Text(
          'Are you sure you want to clear your chat history with ${conversation.participantName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == null || !shouldClear || !context.mounted) return;

    // await context.read<ChatCubit>().clearChatHistory(conversation.id);
  }
}
