import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application/chat/chat_cubit.dart';
import 'application/theme/theme_cubit.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'setup_dependencies.dart';

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
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Live Chat',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
