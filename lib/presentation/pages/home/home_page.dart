import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat_app/application/auth/auth_cubit.dart';
import 'package:live_chat_app/application/auth/auth_state.dart';
import 'package:live_chat_app/presentation/core/router/app_router.dart';
import 'package:live_chat_app/presentation/pages/chat/chat_list_page.dart';
import 'package:live_chat_app/presentation/pages/settings/settings_page.dart';
import 'package:live_chat_app/presentation/core/extensions/build_context_translate_ext.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ChatListPage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status == AuthStatus.authenticated &&
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _pages.asMap().entries.map((entry) {
                  return AnimatedOpacity(
                    opacity: _selectedIndex == entry.key ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: entry.value,
                  );
                }).toList(),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: BottomNavigationBar(
                          currentIndex: _selectedIndex,
                          onTap: _onTabTapped,
                          backgroundColor: Colors.transparent,
                          type: BottomNavigationBarType.fixed,
                          items: [
                            BottomNavigationBarItem(
                              icon: const Icon(Icons.chat_outlined),
                              activeIcon: Icon(
                                Icons.chat,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              label: context.tr.chats,
                            ),
                            BottomNavigationBarItem(
                              icon: const Icon(Icons.settings_outlined),
                              activeIcon: Icon(
                                Icons.settings,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              label: context.tr.settings,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
