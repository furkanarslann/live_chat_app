import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;
  static const String _languageKey = 'language_code';
  static const Locale _defaultLocale = Locale('en');
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('de'), // German
  ];

  LanguageCubit({
    required SharedPreferences prefs,
  })  : _prefs = prefs,
        super(_loadLocale(prefs));

  static Locale _loadLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null &&
        supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      return Locale(languageCode);
    }
    return _defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    await _prefs.setString(_languageKey, locale.languageCode);
    emit(locale);
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      default:
        return languageCode;
    }
  }

  String getCurrentLanguageName() {
    return getLanguageName(state.languageCode);
  }
}
