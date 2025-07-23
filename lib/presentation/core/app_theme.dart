import 'package:flutter/material.dart';

class Elevations {
  static const double base = 0.0;
  static const double card = 1.0;
  static const double dialog = 3.0;
  static const double menu = 4.0;
  static const double modal = 8.0;
}

class Spacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textDisabled;
  final Brightness brightness;

  // Layer opacities
  final double surfaceOpacity;
  final double cardOpacity;
  final double modalOpacity;
  final double overlayOpacity;

  const AppColors._({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,
    required this.brightness,
    required this.surfaceOpacity,
    required this.cardOpacity,
    required this.modalOpacity,
    required this.overlayOpacity,
  });

  factory AppColors.light() {
    const base = Color(0xFF008069);
    const surface = Colors.white;

    return AppColors._(
      primary: base,
      secondary: base,
      background: const Color(0xFFF0F2F5),
      surface: surface,
      surfaceSecondary: surface.withValues(alpha: 0.08),
      textPrimary: const Color(0xDE000000),
      textSecondary: const Color(0x99000000),
      textHint: const Color(0x61000000),
      textDisabled: const Color(0x61000000),
      brightness: Brightness.light,
      surfaceOpacity: 0.04,
      cardOpacity: 0.08,
      modalOpacity: 0.12,
      overlayOpacity: 0.16,
    );
  }

  factory AppColors.dark() {
    const base = Color(0xFF00A884);
    const surface = Color(0xFF111B21);

    return AppColors._(
      primary: base,
      secondary: base,
      background: Colors.black,
      surface: surface,
      surfaceSecondary: surface.withValues(alpha: 0.12),
      textPrimary: Colors.white,
      textSecondary: const Color(0xB3FFFFFF),
      textHint: const Color(0x80FFFFFF),
      textDisabled: const Color(0x80FFFFFF),
      brightness: Brightness.dark,
      surfaceOpacity: 0.08,
      cardOpacity: 0.12,
      modalOpacity: 0.16,
      overlayOpacity: 0.24,
    );
  }
}

class AppTheme {
  static ThemeData light() => _buildTheme(AppColors.light());
  static ThemeData dark() => _buildTheme(AppColors.dark());

  static ThemeData _buildTheme(AppColors colors) {
    final base = colors.brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: colors.brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.background,
        onSurface: colors.textPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor:
            colors.surface.withValues(alpha: colors.overlayOpacity),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
          height: 1.2,
        ),
        toolbarHeight: 64,
      ),
      cardTheme: CardTheme(
        color: colors.surface.withValues(alpha: colors.cardOpacity),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface.withValues(alpha: colors.cardOpacity),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        constraints: const BoxConstraints(minHeight: 48),
        hintStyle: TextStyle(
          color: colors.textHint,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface.withValues(alpha: colors.modalOpacity),
        selectedItemColor: colors.textPrimary,
        unselectedItemColor: colors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.2,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),
      textTheme: (colors.brightness == Brightness.dark
              ? Typography.material2021().white
              : Typography.material2021().black)
          .copyWith(
        bodyLarge: TextStyle(
          color: colors.textPrimary,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          color: colors.textSecondary,
          height: 1.5,
          letterSpacing: 0.25,
        ),
        titleLarge: TextStyle(
          color: colors.textPrimary,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          color: colors.textPrimary,
          height: 1.3,
          letterSpacing: 0.15,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.textPrimary.withValues(alpha: 0.1),
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
