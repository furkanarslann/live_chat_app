import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat_app/presentation/auth/login_page.dart';
import 'package:live_chat_app/presentation/auth/register_page.dart';
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
      routes: [
        // Splash page
        GoRoute(
          path: splash,
          name: splash.name,
          builder: (context, state) => const SplashPage(),
        ),

        // Auth routes
        GoRoute(
          path: login,
          name: login.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          name: register.name,
          builder: (context, state) => const RegisterPage(),
        ),

        // Main app routes
        GoRoute(
          path: home,
          name: home.name,
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
          builder: (context, state) => const ChatSearchPage(),
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
