import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en'));

  void setLanguage(String languageCode) {
    emit(Locale(languageCode));
  }

  bool get isEnglish => state.languageCode == 'en';
  bool get isGerman => state.languageCode == 'de';

  String getCurrentLanguageName() {
    switch (state.languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }
} 