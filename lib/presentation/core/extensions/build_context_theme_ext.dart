import 'package:flutter/material.dart';
import 'package:live_chat_app/presentation/core/app_theme.dart';

extension ColorThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  AppColors get colors => isDarkMode ? AppColors.dark() : AppColors.light();
}
