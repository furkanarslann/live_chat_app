import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/application/auth/auth_state.dart';
import 'package:live_chat_app/application/chat/chat_search_cubit.dart';
import 'package:live_chat_app/di/injection.dart';
import 'package:live_chat_app/domain/chat/chat_conversation.dart';
import 'package:live_chat_app/presentation/auth/login_page.dart';
import 'package:live_chat_app/presentation/auth/register_page.dart';
import 'package:live_chat_app/presentation/chat/chat_page.dart';
import 'package:live_chat_app/presentation/home/home_page.dart';
import 'package:live_chat_app/presentation/chat/chat_list_page.dart';
import 'package:live_chat_app/presentation/chat/chat_search_page.dart';
import 'package:live_chat_app/presentation/chat/chat_participant_profile_page.dart';
import 'package:live_chat_app/presentation/chat/archived_conversations_page.dart';
import 'package:live_chat_app/presentation/settings/settings_page.dart';
import 'package:live_chat_app/presentation/settings/language_settings_page.dart';
import 'package:live_chat_app/presentation/settings/theme_settings_page.dart';
import 'package:live_chat_app/presentation/splash/splash_page.dart';
import 'package:live_chat_app/domain/auth/user.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chatList = '/chat-list';
  static const String archivedConversations = '/archived-conversations';
  static const String chat = '/chat';
  static const String chatSearch = '/chat-search';
  static const String chatParticipantProfile = '/chat-participant-profile';
  static const String settings = '/settings';
  static const String languageSettings = '/language-settings';
  static const String themeSettings = '/theme-settings';

  static GoRouter get router {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        // Get the auth cubit from the context
        final authCubit = context.read<AuthCubit>();
        final authState = authCubit.state;
        // If we're on splash and auth is initialized, redirect based on auth status
        if (state.matchedLocation == splash &&
            authState.status != AuthStatus.initial) {
          switch (authState.status) {
            case AuthStatus.authenticated:
              return home;
            case AuthStatus.unauthenticated:
            case AuthStatus.failure:
              return login;
            case AuthStatus.initial:
              // Stay on splash while auth is initializing
              return null;
          }
        }
        return null;
      },
      routes: [
        // Splash page
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Auth routes
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // Main app routes
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),

        // Chat routes
        GoRoute(
          path: chatList,
          name: chatList.name,
          builder: (context, state) => const ChatListPage(),
        ),
        GoRoute(
          path: archivedConversations,
          name: archivedConversations.name,
          builder: (context, state) => const ArchivedConversationsPage(),
        ),
        GoRoute(
          path: chatSearch,
          name: chatSearch.name,
          builder: (_, __) => BlocProvider(
            create: (_) => getIt<ChatSearchCubit>(),
            child: const ChatSearchPage(),
          ),
        ),

        // Settings routes
        GoRoute(
          path: settings,
          name: settings.name,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: languageSettings,
          name: languageSettings.name,
          builder: (context, state) => const LanguageSettingsPage(),
        ),
        GoRoute(
          path: themeSettings,
          name: themeSettings.name,
          builder: (context, state) => const ThemeSettingsPage(),
        ),
        GoRoute(
          path: chatParticipantProfile,
          name: chatParticipantProfile.name,
          builder: (context, state) {
            final participant = state.extra as User;
            return ChatParticipantProfilePage(participant: participant);
          },
        ),
        GoRoute(
          path: chat,
          name: chat.name,
          pageBuilder: (context, state) {
            final conversation = state.extra as ChatConversation;
            return CustomTransitionPage(
              child: ChatPage(conversation: conversation),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          },
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}

extension _AppRouterNamesX on String {
  String get name {
    final name = split('/').last;
    if (name.isEmpty) return 'splash';
    return name;
  }
}
