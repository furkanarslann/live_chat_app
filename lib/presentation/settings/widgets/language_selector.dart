import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';
import 'country_flag.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, currentLocale) {
        final languageCubit = context.read<LanguageCubit>();

        return PopupMenuButton<Locale>(
          initialValue: currentLocale,
          onSelected: (Locale locale) {
            languageCubit.setLocale(locale);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountryFlag(
                  languageCode: currentLocale.languageCode,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  languageCubit.getCurrentLanguageName(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          itemBuilder: (BuildContext context) {
            return LanguageCubit.supportedLocales.map((Locale locale) {
              return PopupMenuItem<Locale>(
                value: locale,
                child: _LanguageOption(
                  locale: locale,
                  languageName:
                      languageCubit.getLanguageName(locale.languageCode),
                  isSelected: currentLocale.languageCode == locale.languageCode,
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final Locale locale;
  final String languageName;
  final bool isSelected;

  const _LanguageOption({
    required this.locale,
    required this.languageName,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CountryFlag(
          languageCode: locale.languageCode,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            languageName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }
}
