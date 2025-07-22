import 'package:flutter/material.dart';

class AppTheme {
  // Semantic colors for status indication
  static const statusColors = {
    'online': Color(0xFF4CAF50),
    'offline': Color(0xFF9E9E9E),
    'busy': Color(0xFFF44336),
    'away': Color(0xFFFF9800),
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
    const background = Color(0xFF0B141A);

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
        // Ensure proper contrast ratios
        onBackground: Colors.white.withValues(alpha: 0.95),
        onSurface: Colors.white.withValues(alpha: 0.95),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: layerOpacities['overlay']!),
        elevation: elevations['base'],
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2, // Improve readability
        ),
        toolbarHeight: 64, // Ensure minimum touch target
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
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.withValues(alpha: 0.7),
        type: BottomNavigationBarType.fixed,
        elevation: elevations['base'],
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: layerOpacities['modal']!),
        indicatorColor: primary.withValues(alpha: 0.15),
        height: 56, // Standard Material height
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(
              color: primary,
              size: 24,
              opacity: 0.95,
            );
          }
          return IconThemeData(
            color: Colors.grey.withValues(alpha: 0.7),
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.1,
            );
          }
          return TextStyle(
            color: Colors.grey.withValues(alpha: 0.7),
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
        constraints:
            const BoxConstraints(minHeight: 48), // Ensure minimum touch target
      ),
      textTheme: Typography.material2021().white.copyWith(
            // Improve text contrast and readability
            bodyLarge: Typography.material2021().white.bodyLarge?.copyWith(
                  height: 1.5,
                  letterSpacing: 0.15,
                ),
            bodyMedium: Typography.material2021().white.bodyMedium?.copyWith(
                  height: 1.5,
                  letterSpacing: 0.25,
                ),
            titleLarge: Typography.material2021().white.titleLarge?.copyWith(
                  height: 1.2,
                  letterSpacing: 0,
                ),
            titleMedium: Typography.material2021().white.titleMedium?.copyWith(
                  height: 1.3,
                  letterSpacing: 0.15,
                ),
          ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        space: 1,
      ),
      // Animation durations
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory, // More subtle ripple effect
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
        // Ensure proper contrast ratios
        onBackground: Colors.black.withValues(alpha: 0.87),
        onSurface: Colors.black.withValues(alpha: 0.87),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: layerOpacities['overlay']!),
        elevation: elevations['base'],
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey.withValues(alpha: 0.8),
        type: BottomNavigationBarType.fixed,
        elevation: elevations['base'],
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: layerOpacities['modal']!),
        indicatorColor: primary.withValues(alpha: 0.12),
        height: 56, // Standard Material height
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return IconThemeData(
              color: primary,
              size: 24,
              opacity: 0.95,
            );
          }
          return IconThemeData(
            color: Colors.grey.withValues(alpha: 0.8),
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.1,
            );
          }
          return TextStyle(
            color: Colors.grey.withValues(alpha: 0.8),
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
      ),
      textTheme: Typography.material2021().black.copyWith(
            bodyLarge: Typography.material2021().black.bodyLarge?.copyWith(
                  height: 1.5,
                  letterSpacing: 0.15,
                ),
            bodyMedium: Typography.material2021().black.bodyMedium?.copyWith(
                  height: 1.5,
                  letterSpacing: 0.25,
                ),
            titleLarge: Typography.material2021().black.titleLarge?.copyWith(
                  height: 1.2,
                  letterSpacing: 0,
                ),
            titleMedium: Typography.material2021().black.titleMedium?.copyWith(
                  height: 1.3,
                  letterSpacing: 0.15,
                ),
          ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.1),
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
