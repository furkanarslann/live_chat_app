import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/chat/chat_state.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

class ChatFilterChips extends StatelessWidget {
  const ChatFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return ClipRect(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: Spacing.sm,
                children: [
                  ChatFilterChip(filter: ChatFilter.all),
                  ChatFilterChip(filter: ChatFilter.unread),
                  ChatFilterChip(filter: ChatFilter.favorites),
                  ChatFilterChip(filter: ChatFilter.groups),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChatFilterChip extends StatelessWidget {
  final ChatFilter filter;

  const ChatFilterChip({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final isSelected = state.activeFilter == filter;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        String getLabel() {
          switch (filter) {
            case ChatFilter.all:
              return context.tr.all;
            case ChatFilter.unread:
              return context.tr.unread;
            case ChatFilter.favorites:
              return context.tr.favorites;
            case ChatFilter.groups:
              return context.tr.groups;
          }
        }

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
              onTap: () {
                context.read<ChatCubit>().changeFilter(filter);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 68,
                  minHeight: 36,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    getLabel(),
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
      },
    );
  }
}
