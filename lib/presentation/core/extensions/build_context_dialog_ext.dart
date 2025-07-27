import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/widgets/confirmation_dialog.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

extension BuildContextDialogExt on BuildContext {
  /// Shows a sign out confirmation dialog
  /// Returns true if user confirms, false if cancelled
  Future<bool?> showSignOutDialog() async {
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: context.tr.signOut,
        description: context.tr.signOutConfirmation,
        icon: Icons.logout_rounded,
        iconColor: Theme.of(this).colorScheme.error,
        cancelText: context.tr.cancel,
        actionText: context.tr.signOut,
        isDestructive: true,
      ),
    );
  }

  /// Shows a clear chat history confirmation dialog
  /// Returns true if user confirms, false if cancelled
  Future<bool?> showClearChatDialog(String participantName) async {
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: context.tr.clearChatHistoryTitle,
        description: context.tr.clearChatHistoryMessage(participantName),
        icon: Icons.delete_outline_rounded,
        iconColor: Theme.of(this).colorScheme.error,
        cancelText: context.tr.cancel,
        actionText: context.tr.clear,
        isDestructive: true,
      ),
    );
  }
} 