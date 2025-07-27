import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';
import 'package:live_chat_app/application/theme/theme_cubit.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_dialog_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/user_avatar.dart';
import 'package:live_chat_app/presentation/settings/language_settings_page.dart';
import 'package:live_chat_app/presentation/settings/theme_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _AppBar(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProfileSection()),
          const SliverToBoxAdapter(child: Divider(height: 2)),
          _AppSettingsSection(),
          _HelpSection(),
          _AccountSection(),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      title: Text(
        context.tr.settings,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: user.displayPhotoUrl,
                radius: 40,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      context.tr.available,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SettingsSection(
      title: context.tr.account,
      items: [
        _SettingsItem(
          icon: Icons.logout,
          iconColor: colorScheme.error,
          title: context.tr.signOut,
          onTap: () => _showSignOutConfirmationDialog(context),
        ),
      ],
    );
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    final confirmed = await context.showSignOutDialog();

    if (confirmed == true) {
      if (context.mounted) {
        context.read<AuthCubit>().signOut();
      }
    }
  }
}

class _AppSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SettingsSection(
      title: context.tr.appSettings,
      items: [
        BlocBuilder<LanguageCubit, Locale>(
          builder: (context, state) {
            return _SettingsItem(
              icon: Icons.language,
              iconColor: colorScheme.primary,
              title: context.tr.language,
              subtitle: context.read<LanguageCubit>().getCurrentLanguageName(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSettingsPage(),
                  ),
                );
              },
            );
          },
        ),
        _ThemeSettingsItem(),
      ],
    );
  }
}

class _ThemeSettingsItem extends StatelessWidget {
  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.tr.light;
      case ThemeMode.dark:
        return context.tr.dark;
      case ThemeMode.system:
        return context.tr.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, state) {
        return _SettingsItem(
          icon: state == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
          iconColor: colorScheme.primary,
          title: context.tr.theme,
          subtitle: _getThemeModeName(context, state),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeSettingsPage(),
              ),
            );
          },
        );
      },
    );
  }
}

class _HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SettingsSection(
      title: context.tr.help,
      items: [
        _SettingsItem(
          icon: Icons.help_outline,
          iconColor: colorScheme.primary,
          title: context.tr.helpCenter,
          onTap: () {
            //TODO(Furkan): Implement help center
          },
        ),
        _SettingsItem(
          icon: Icons.info_outline,
          iconColor: colorScheme.primary,
          title: context.tr.about,
          onTap: () {
            //TODO(Furkan): Implement about page
          },
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.sm,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.colors.textPrimary,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
