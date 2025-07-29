import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/application/auth/user_cubit.dart';
import 'package:live_chat_app/application/chat/chat_cubit.dart';
import 'package:live_chat_app/application/language/language_cubit.dart';
import 'package:live_chat_app/application/theme/theme_cubit.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';
import 'package:live_chat_app/presentation/core/router/app_router.dart';
import 'package:live_chat_app/presentation/splash/splash_page.dart';
import 'package:live_chat_app/di/injection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LiveChatApp extends StatelessWidget {
  const LiveChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<ChatCubit>(create: (_) => getIt<ChatCubit>()),
        BlocProvider<UserCubit>(create: (_) => getIt<UserCubit>()),
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<LanguageCubit>(create: (_) => getIt<LanguageCubit>()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state;
          final locale = context.watch<LanguageCubit>().state;

          return MaterialApp(
            title: 'Live Chat',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
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
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
