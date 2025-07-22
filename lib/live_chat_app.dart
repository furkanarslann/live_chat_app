import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'application/chat/chat_cubit.dart';
import 'application/theme/theme_cubit.dart';
import 'application/language/language_cubit.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'setup_dependencies.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LiveChatApp extends StatelessWidget {
  const LiveChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(
          create: (_) => getIt<ChatCubit>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<LanguageCubit>(
          create: (_) => LanguageCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state;
          final locale = context.watch<LanguageCubit>().state;

          return MaterialApp(
            title: 'Live Chat',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('de'), // German
            ],
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
