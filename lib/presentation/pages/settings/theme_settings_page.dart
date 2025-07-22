import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/theme/theme_cubit.dart';
import '../../core/app_theme.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing['md']!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing['md']),
                  _buildThemeOption(
                    context: context,
                    title: 'Light',
                    icon: Icons.light_mode_outlined,
                    isSelected: context.select(
                      (ThemeCubit cubit) => cubit.state == ThemeMode.light,
                    ),
                    onTap: () =>
                        context.read<ThemeCubit>().setTheme(ThemeMode.light),
                  ),
                  SizedBox(height: AppTheme.spacing['sm']),
                  _buildThemeOption(
                    context: context,
                    title: 'Dark',
                    icon: Icons.dark_mode_outlined,
                    isSelected: context.select(
                      (ThemeCubit cubit) => cubit.state == ThemeMode.dark,
                    ),
                    onTap: () =>
                        context.read<ThemeCubit>().setTheme(ThemeMode.dark),
                  ),
                  SizedBox(height: AppTheme.spacing['sm']),
                  _buildThemeOption(
                    context: context,
                    title: 'System',
                    icon: Icons.settings_suggest_outlined,
                    isSelected: context.select(
                      (ThemeCubit cubit) => cubit.state == ThemeMode.system,
                    ),
                    onTap: () =>
                        context.read<ThemeCubit>().setTheme(ThemeMode.system),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppTheme.spacing['md']!),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.dividerColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacing['sm']!),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.1)
                    : theme.cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                size: 24,
              ),
            ),
            SizedBox(width: AppTheme.spacing['md']),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
