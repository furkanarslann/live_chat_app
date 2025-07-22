import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  void toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
} 