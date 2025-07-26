import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? child;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: context.colors.primary.withValues(alpha: 0.1),
      backgroundImage: _getImageProvider(),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  ImageProvider _getImageProvider() {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImageProvider(
        imageUrl,
        errorListener: (error) => debugPrint('Error loading avatar: $error'),
      );
    }
    return AssetImage(imageUrl);
  }
}
