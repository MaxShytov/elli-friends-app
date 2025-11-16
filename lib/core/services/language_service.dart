// lib/core/services/language_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/supported_languages.dart';

/// Service for managing app language
class LanguageService {
  static const String _languageKey = 'app_language';

  /// Get saved language or device locale
  static Future<Locale> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      return Locale(languageCode);
    }

    // Return device locale if supported, otherwise English
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (SupportedLanguages.isSupported(deviceLocale)) {
      return deviceLocale;
    }

    return const Locale('en');
  }

  /// Save language preference
  static Future<void> saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  /// Get lesson path for current language
  static String getLessonPath(String lessonId, String languageCode) {
    return 'assets/data/lessons/$languageCode/$lessonId.json';
  }
}
