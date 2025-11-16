// lib/core/constants/supported_languages.dart

import 'package:flutter/material.dart';

/// Supported languages in the app
class SupportedLanguages {
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('fr', ''), // French
    Locale('de', ''), // German
    Locale('it', ''), // Italian
    Locale('my', ''), // Burmese (Myanmar)
  ];

  /// Language names in their native form
  static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'my': 'မြန်မာ', // Burmese
  };

  /// TTS language codes for flutter_tts
  static const Map<String, String> ttsLanguageCodes = {
    'en': 'en-US',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'it': 'it-IT',
    'my': 'my-MM', // Burmese
  };

  /// Get TTS language code for a locale
  static String getTtsLanguageCode(String languageCode) {
    return ttsLanguageCodes[languageCode] ?? 'en-US';
  }

  /// Get language name for a locale
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'English';
  }

  /// Check if a locale is supported
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}
