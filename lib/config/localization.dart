import 'package:flutter/material.dart';

class AppLocalization {
  static const Map<String, Locale> supportedLocales = {
    'en': Locale('en', 'US'),
    'ur': Locale('ur', 'PK'),
    'ps': Locale('ps', 'AF'),
  };

  static const Map<String, String> languageNames = {
    'en': 'English',
    'ur': 'اردو (Urdu)',
    'ps': 'پښتو (Pashto)',
  };

  static const Map<String, TextDirection> textDirections = {
    'en': TextDirection.ltr,
    'ur': TextDirection.rtl,
    'ps': TextDirection.rtl,
  };

  static Locale getLocale(String languageCode) {
    return supportedLocales[languageCode] ?? const Locale('en', 'US');
  }

  static TextDirection getTextDirection(String languageCode) {
    return textDirections[languageCode] ?? TextDirection.ltr;
  }

  static bool isRTL(String languageCode) {
    return textDirections[languageCode] == TextDirection.rtl;
  }
}
