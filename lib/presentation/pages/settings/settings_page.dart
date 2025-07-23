import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';
import 'package:live_chat_app/application/theme/theme_cubit.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_theme_ext.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/pages/settings/language_settings_page.dart';
import 'package:live_chat_app/presentation/pages/settings/theme_settings_page.dart';

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
          SliverToBoxAdapter(
            child: _ProfileSection(),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          _AccountSection(),
          _AppSettingsSection(),
          _HelpSection(),
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
      title: Text(context.tr.settings),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.yourName,
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
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              //TODO(Furkan): Implement QR code
            },
            tooltip: context.tr.showQrCode,
          ),
        ],
      ),
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
          icon: Icons.key,
          iconColor: colorScheme.primary,
          title: context.tr.privacy,
          onTap: () {
            //TODO(Furkan): Implement privacy settings
          },
        ),
        _SettingsItem(
          icon: Icons.chat_bubble_outline,
          iconColor: colorScheme.primary,
          title: context.tr.chatSettings,
          onTap: () {
            //TODO(Furkan): Implement chat settings
          },
        ),
        _SettingsItem(
          icon: Icons.notifications_none,
          iconColor: colorScheme.primary,
          title: context.tr.notifications,
          onTap: () {
            //TODO(Furkan): Implement notification settings
          },
        ),
      ],
    );
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
        const SizedBox(height: kToolbarHeight)
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          ...items,
          const SizedBox(height: Spacing.sm),
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
                    style: theme.textTheme.titleMedium?.copyWith(
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
