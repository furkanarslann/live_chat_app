import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';

enum GlassySnackBarType { success, failure, info }

class GlassySnackBar extends StatelessWidget {
  const GlassySnackBar({super.key, required this.message, required this.type});

  final String message;
  final GlassySnackBarType type;

  static void show(
    BuildContext context, {
    required String message,
    required GlassySnackBarType type,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          content: GlassySnackBar(message: message, type: type),
        ),
      );
  }

  Color _getAccentColor(BuildContext context) {
    switch (type) {
      case GlassySnackBarType.success:
        return const Color(0xFF00E676);
      case GlassySnackBarType.failure:
        return const Color(0xFFFF5252);
      case GlassySnackBarType.info:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case GlassySnackBarType.success:
        return Icons.check_circle_rounded;
      case GlassySnackBarType.failure:
        return Icons.error_rounded;
      case GlassySnackBarType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.background.withValues(alpha: 0.7),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: (1 - value) * 1.8,
                            child: child,
                          );
                        },
                        child: Icon(_getIcon(), color: accentColor, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
