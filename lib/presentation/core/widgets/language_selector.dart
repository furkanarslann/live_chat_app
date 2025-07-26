import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';

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
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
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
                child: Text(languageCubit.getLanguageName(locale.languageCode)),
              );
            }).toList();
          },
        );
      },
    );
  }
}
