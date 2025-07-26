import 'package:flutter/material.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  bool get _areAllRequirementsMet {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requirements = [
      _Requirement(
        title: 'At least 8 characters',
        isMet: password.length >= 8,
      ),
      _Requirement(
        title: 'Contains uppercase letter',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      _Requirement(
        title: 'Contains lowercase letter',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      _Requirement(
        title: 'Contains number',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      _Requirement(
        title: 'Contains special character',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: password.isEmpty || _areAllRequirementsMet
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password requirements:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...requirements.map((req) => _RequirementTile(
                        title: req.title,
                        isMet: req.isMet,
                        theme: theme,
                      )),
                ],
              ),
            ),
    );
  }
}

class _Requirement {
  final String title;
  final bool isMet;

  const _Requirement({
    required this.title,
    required this.isMet,
  });
}

class _RequirementTile extends StatelessWidget {
  final String title;
  final bool isMet;
  final ThemeData theme;

  const _RequirementTile({
    required this.title,
    required this.isMet,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isMet ? Icons.check_circle : Icons.cancel,
              key: ValueKey(isMet),
              size: 16,
              color: isMet
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
