import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension BuildContextTranslateX on BuildContext {
  /// Shortcut to get the localized strings from the AppLocalizations. (e.g., context.tr.appTitle)
  AppLocalizations get tr => AppLocalizations.of(this)!;

  Locale get defaultLocale => const Locale('tr');
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  List<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    return AppLocalizations.localizationsDelegates;
  }
}
