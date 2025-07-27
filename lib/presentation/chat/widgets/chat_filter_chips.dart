import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

class ChatFilterChips extends StatelessWidget {
  const ChatFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ChatFilterChip(
                label: context.tr.all,
                isSelected: true,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
              const SizedBox(width: Spacing.sm),
              ChatFilterChip(
                label: context.tr.unread,
                isSelected: false,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
              const SizedBox(width: Spacing.sm),
              ChatFilterChip(
                label: context.tr.favorites,
                isSelected: false,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
              const SizedBox(width: Spacing.sm),
              ChatFilterChip(
                label: context.tr.groups,
                isSelected: false,
                onTap: () {
                  // TODO(Furkan): Implement filter
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatFilterChip extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatFilterChip({
    super.key,
    this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer
            : theme.cardColor.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 68,
              minHeight: 36,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 16 : 12,
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      semanticLabel: 'Add filter',
                    )
                  : Text(
                      label!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
