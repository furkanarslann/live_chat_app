import 'package:flutter/material.dart';
import 'package:live_chat_app/domain/auth/user.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';

class ChatUserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const ChatUserTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: UserAvatar(
          imageUrl: user.displayPhotoUrl,
          radius: 20,
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: const Icon(
          Icons.chevron_right_outlined,
        ),
      ),
    );
  }
} 