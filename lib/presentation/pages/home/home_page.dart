import 'dart:ui';
import 'package:flutter/material.dart';
import '../chat/chat_list_page.dart';
import '../settings/settings_page.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          // Page content with fade transition
          SafeArea(
            child: IndexedStack(
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
          ),

          // Blurred bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0.8),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
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
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      unselectedItemColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      type: BottomNavigationBarType.fixed,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      elevation: 0,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.chat_outlined),
                          activeIcon: Icon(Icons.chat),
                          label: 'Chats',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.settings_outlined),
                          activeIcon: Icon(Icons.settings),
                          label: 'Settings',
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
    );
  }
}
