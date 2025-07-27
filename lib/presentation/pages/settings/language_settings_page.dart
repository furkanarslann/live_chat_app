import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';
import 'package:live_chat_app/presentation/core/widgets/country_flag.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  String _getLanguageName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return context.tr.english;
      case 'de':
        return context.tr.german;
      default:
        return languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.languageSettings),
      ),
      body: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, currentLocale) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final locale in LanguageCubit.supportedLocales) ...[
                if (locale != LanguageCubit.supportedLocales.first)
                  const SizedBox(height: 16),
                _LanguageOption(
                  title: _getLanguageName(context, locale.languageCode),
                  languageCode: locale.languageCode,
                  isSelected: currentLocale.languageCode == locale.languageCode,
                  onTap: () {
                    context.read<LanguageCubit>().setLocale(locale);
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  shape: BoxShape.circle,
                ),
                child: CountryFlag(
                  languageCode: languageCode,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
