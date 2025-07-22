import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/theme/theme_cubit.dart';
import '../../core/app_theme.dart';
import 'theme_settings_page.dart';

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
      title: const Text('Settings'),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(AppTheme.spacing['md']!),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing['md']),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Name',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppTheme.spacing['xs']),
                Text(
                  'Available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.statusColors['online'],
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
            tooltip: 'Show QR code',
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
      title: 'Account',
      items: [
        _SettingsItem(
          icon: Icons.key,
          iconColor: colorScheme.primary,
          title: 'Privacy',
          onTap: () {
            //TODO(Furkan): Implement privacy settings
          },
        ),
        _SettingsItem(
          icon: Icons.chat_bubble_outline,
          iconColor: colorScheme.primary,
          title: 'Chats',
          onTap: () {
            //TODO(Furkan): Implement chat settings
          },
        ),
        _SettingsItem(
          icon: Icons.notifications_none,
          iconColor: colorScheme.primary,
          title: 'Notifications',
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
      title: 'App Settings',
      items: [
        _SettingsItem(
          icon: Icons.language,
          iconColor: colorScheme.primary,
          title: 'Language',
          subtitle: 'English',
          onTap: () {
            //TODO(Furkan): Implement language settings
          },
        ),
        _ThemeSettingsItem(),
      ],
    );
  }
}

class _ThemeSettingsItem extends StatelessWidget {
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
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
          title: 'Theme',
          subtitle: _getThemeModeName(state),
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
      title: 'Help',
      items: [
        _SettingsItem(
          icon: Icons.help_outline,
          iconColor: colorScheme.primary,
          title: 'Help Center',
          onTap: () {
            //TODO(Furkan): Implement help center
          },
        ),
        _SettingsItem(
          icon: Icons.info_outline,
          iconColor: colorScheme.primary,
          title: 'About',
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
            padding: EdgeInsets.all(AppTheme.spacing['md']!),
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
          SizedBox(height: AppTheme.spacing['sm']),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing['md']!,
          vertical: AppTheme.spacing['sm']!,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing['sm']!),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: AppTheme.spacing['md']),
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
                    SizedBox(height: AppTheme.spacing['xxs']),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
