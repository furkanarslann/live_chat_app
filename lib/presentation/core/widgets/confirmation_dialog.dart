import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import '../app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String cancelText;
  final String actionText;
  final VoidCallback? onCancelled;
  final VoidCallback? onAction;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.cancelText,
    required this.actionText,
    this.onCancelled,
    this.onAction,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: Elevations.dialog,
              backgroundColor: colorScheme.surface,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon and title section
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, iconValue, child) {
                        return Transform.scale(
                          scale: iconValue,
                          child: Container(
                            padding: const EdgeInsets.all(Spacing.md),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 32,
                              color: iconColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.lg),
                    // Buttons section
                    Row(
                      children: [
                        Expanded(
                          child: _DialogButton(
                            text: cancelText,
                            isOutlined: true,
                            onPressed: () {
                              context.pop(false);
                              onCancelled?.call();
                            },
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: _DialogButton(
                            text: actionText,
                            isDestructive: isDestructive,
                            textColor: isDestructive
                                ? context.colors.background
                                : null,
                            onPressed: () {
                              context.pop(true);
                              onAction?.call();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isDestructive;
  final Color? textColor;

  const _DialogButton({
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isDestructive = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 48,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? colorScheme.onSurface,
                    ) ??
                    const TextStyle(),
                child: Text(text),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDestructive ? colorScheme.error : colorScheme.primary,
                foregroundColor:
                    isDestructive ? colorScheme.onError : colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ??
                          (isDestructive
                              ? colorScheme.onError
                              : colorScheme.onPrimary),
                    ) ??
                    const TextStyle(),
                child: Text(text),
              ),
            ),
    );
  }
}
