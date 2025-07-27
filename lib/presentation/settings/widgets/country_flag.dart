import 'package:flutter/material.dart';

class CountryFlag extends StatelessWidget {
  final String languageCode;
  final double size;

  const CountryFlag({
    super.key,
    required this.languageCode,
    this.size = 20,
  });

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸'; // US flag for English
      case 'de':
        return '🇩🇪'; // German flag
      default:
        return '🌐'; // Globe as fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getFlagEmoji(languageCode),
      style: TextStyle(fontSize: size),
    );
  }
}
