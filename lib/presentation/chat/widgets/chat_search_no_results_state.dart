import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

class ChatSearchNoResultsState extends StatelessWidget {
  final String query;

  const ChatSearchNoResultsState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              context.tr.noSearchResults,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              context.tr.noResultsForQuery(query),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 