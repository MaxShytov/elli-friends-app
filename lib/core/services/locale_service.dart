// lib/core/services/locale_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/supported_languages.dart';
import 'audio_manager.dart';

/// Global locale service for managing app language
class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  /// Initialize locale from saved preferences
  Future<void> initialize() async {
    _currentLocale = await _getSavedLanguage();
    notifyListeners();
  }

  /// Change the app locale
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    await _saveLanguage(locale);
    await AudioManager().changeLanguage(locale.languageCode);
    notifyListeners();
  }

  /// Get saved language or device locale
  Future<Locale> _getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('app_language');

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
  Future<void> _saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', locale.languageCode);
  }
}
