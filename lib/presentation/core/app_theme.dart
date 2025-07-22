import 'package:flutter/material.dart';

class AppTheme {
  // Semantic colors for status indication
  static const statusColors = {
    'online': Color(0xFF4CAF50),
    'offline': Color(0xFF9E9E9E),
    'busy': Color(0xFFF44336),
    'away': Color(0xFFFF9800),
  };

  // Text colors for consistent typography
  static const textColors = {
    'dark': {
      'primary': Colors.white,
      'secondary': Color(0xB3FFFFFF), // 70% white
      'disabled': Color(0x80FFFFFF), // 50% white
      'hint': Color(0x80FFFFFF), // 50% white
    },
    'light': {
      'primary': Color(0xDE000000), // 87% black
      'secondary': Color(0x99000000), // 60% black
      'disabled': Color(0x61000000), // 38% black
      'hint': Color(0x61000000), // 38% black
    },
  };

  // Elevation levels for consistent hierarchy
  static const elevations = {
    'base': 0.0,
    'card': 1.0,
    'dialog': 3.0,
    'menu': 4.0,
    'modal': 8.0,
  };

  // Standard spacing units
  static const spacing = {
    'xxs': 2.0,
    'xs': 4.0,
    'sm': 8.0,
    'md': 16.0,
    'lg': 24.0,
    'xl': 32.0,
    'xxl': 48.0,
  };

  static ThemeData get darkTheme {
    const primary = Color(0xFF00A884);
    const surface = Color(0xFF111B21);
    const background = Color.fromARGB(255, 0, 0, 0);

    // Layer opacity levels for proper depth
    const layerOpacities = {
      'surface': 0.08,
      'card': 0.12,
      'modal': 0.16,
      'overlay': 0.24,
    };

    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primary,
        primaryContainer: primary.withValues(alpha: 0.15),
        onPrimaryContainer: primary,
        secondary: primary,
        surface: surface,
        background: background,
        error: const Color(0xFFE55959),
        onBackground: textColors['dark']!['primary']!,
        onSurface: textColors['dark']!['primary']!,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: layerOpacities['overlay']!),
        elevation: elevations['base'],
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColors['dark']!['primary'],
          height: 1.2,
        ),
        toolbarHeight: 64,
      ),
      cardTheme: CardTheme(
        color: surface.withValues(alpha: layerOpacities['card']!),
        elevation: elevations['card'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: layerOpacities['modal']!),
        selectedItemColor: textColors['dark']!['primary'],
        unselectedItemColor: textColors['dark']!['secondary'],
        selectedLabelStyle: TextStyle(
          color: textColors['dark']!['primary'],
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: TextStyle(
          color: textColors['dark']!['secondary'],
          fontSize: 11,
          letterSpacing: 0.2,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: elevations['base'],
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: layerOpacities['modal']!),
        indicatorColor: primary.withValues(alpha: 0.15),
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primary,
              size: 24,
              opacity: 0.95,
            );
          }
          return IconThemeData(
            color: textColors['dark']!['secondary'],
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: textColors['dark']!['primary'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.1,
            );
          }
          return TextStyle(
            color: textColors['dark']!['secondary'],
            fontSize: 11,
            letterSpacing: 0.2,
            height: 1.1,
          );
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: layerOpacities['card']!),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        constraints: const BoxConstraints(minHeight: 48),
        hintStyle: TextStyle(
          color: textColors['dark']!['hint'],
          fontSize: 16,
          height: 1.5,
        ),
      ),
      textTheme: Typography.material2021().white.copyWith(
            bodyLarge: Typography.material2021().white.bodyLarge?.copyWith(
                  color: textColors['dark']!['primary'],
                  height: 1.5,
                  letterSpacing: 0.15,
                ),
            bodyMedium: Typography.material2021().white.bodyMedium?.copyWith(
                  color: textColors['dark']!['secondary'],
                  height: 1.5,
                  letterSpacing: 0.25,
                ),
            titleLarge: Typography.material2021().white.titleLarge?.copyWith(
                  color: textColors['dark']!['primary'],
                  height: 1.2,
                  letterSpacing: 0,
                ),
            titleMedium: Typography.material2021().white.titleMedium?.copyWith(
                  color: textColors['dark']!['primary'],
                  height: 1.3,
                  letterSpacing: 0.15,
                ),
          ),
      dividerTheme: DividerThemeData(
        color: textColors['dark']!['primary']!.withValues(alpha: 0.1),
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData get lightTheme {
    const primary = Color(0xFF008069);
    const surface = Colors.white;
    const background = Color(0xFFF0F2F5);

    // Layer opacity levels for proper depth
    const layerOpacities = {
      'surface': 0.04,
      'card': 0.08,
      'modal': 0.12,
      'overlay': 0.16,
    };

    return ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primary.withValues(alpha: 0.12),
        onPrimaryContainer: primary,
        secondary: primary,
        surface: surface,
        background: background,
        error: const Color(0xFFDC3545),
        onBackground: textColors['light']!['primary']!,
        onSurface: textColors['light']!['primary']!,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: layerOpacities['overlay']!),
        elevation: elevations['base'],
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColors['light']!['primary'],
          height: 1.2,
        ),
        toolbarHeight: 64,
      ),
      cardTheme: CardTheme(
        color: surface.withValues(alpha: layerOpacities['card']!),
        elevation: elevations['card'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: layerOpacities['modal']!),
        selectedItemColor: textColors['light']!['primary'],
        unselectedItemColor: textColors['light']!['secondary'],
        selectedLabelStyle: TextStyle(
          color: textColors['light']!['primary'],
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: TextStyle(
          color: textColors['light']!['secondary'],
          fontSize: 11,
          letterSpacing: 0.2,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: elevations['base'],
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: layerOpacities['modal']!),
        indicatorColor: primary.withValues(alpha: 0.12),
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primary,
              size: 24,
              opacity: 0.95,
            );
          }
          return IconThemeData(
            color: textColors['light']!['secondary'],
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: textColors['light']!['primary'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.1,
            );
          }
          return TextStyle(
            color: textColors['light']!['secondary'],
            fontSize: 11,
            letterSpacing: 0.2,
            height: 1.1,
          );
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: layerOpacities['card']!),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        constraints: const BoxConstraints(minHeight: 48),
        hintStyle: TextStyle(
          color: textColors['light']!['hint'],
          fontSize: 16,
          height: 1.5,
        ),
      ),
      textTheme: Typography.material2021().black.copyWith(
            bodyLarge: Typography.material2021().black.bodyLarge?.copyWith(
                  color: textColors['light']!['primary'],
                  height: 1.5,
                  letterSpacing: 0.15,
                ),
            bodyMedium: Typography.material2021().black.bodyMedium?.copyWith(
                  color: textColors['light']!['secondary'],
                  height: 1.5,
                  letterSpacing: 0.25,
                ),
            titleLarge: Typography.material2021().black.titleLarge?.copyWith(
                  color: textColors['light']!['primary'],
                  height: 1.2,
                  letterSpacing: 0,
                ),
            titleMedium: Typography.material2021().black.titleMedium?.copyWith(
                  color: textColors['light']!['primary'],
                  height: 1.3,
                  letterSpacing: 0.15,
                ),
          ),
      dividerTheme: DividerThemeData(
        color: textColors['light']!['primary']!.withValues(alpha: 0.1),
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
