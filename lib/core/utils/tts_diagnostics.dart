// lib/core/utils/tts_diagnostics.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Утилита для диагностики TTS
class TtsDiagnostics {
  static final FlutterTts _tts = FlutterTts();

  /// Получить список доступных языков
  static Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _tts.getLanguages;
      if (languages is List) {
        return languages.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  /// Получить список доступных голосов
  static Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        return voices.map((voice) {
          if (voice is Map) {
            return {
              'name': voice['name']?.toString() ?? 'Unknown',
              'locale': voice['locale']?.toString() ?? 'Unknown',
            };
          }
          return {'name': 'Unknown', 'locale': 'Unknown'};
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return [];
    }
  }

  /// Проверить доступность языка
  static Future<bool> isLanguageAvailable(String languageCode) async {
    final languages = await getAvailableLanguages();
    return languages.any((lang) => 
      lang.toLowerCase().startsWith(languageCode.toLowerCase()));
  }

  /// Проверить доступность голоса для локали
  static Future<bool> isVoiceAvailable(String locale) async {
    final voices = await getAvailableVoices();
    return voices.any((voice) => 
      voice['locale']?.toLowerCase() == locale.toLowerCase());
  }

  /// Получить информацию о TTS для конкретного языка
  static Future<Map<String, dynamic>> getLanguageInfo(String languageCode) async {
    final languages = await getAvailableLanguages();
    final voices = await getAvailableVoices();
    
    final matchingLanguages = languages.where((lang) => 
      lang.toLowerCase().startsWith(languageCode.toLowerCase())).toList();
    
    final matchingVoices = voices.where((voice) => 
      voice['locale']?.toLowerCase().startsWith(languageCode.toLowerCase()) ?? false).toList();

    return {
      'languageCode': languageCode,
      'isAvailable': matchingLanguages.isNotEmpty,
      'hasVoices': matchingVoices.isNotEmpty,
      'languages': matchingLanguages,
      'voices': matchingVoices,
    };
  }

  /// Распечатать полную диагностику TTS
  static Future<void> printFullDiagnostics() async {
    debugPrint('\n========== TTS DIAGNOSTICS ==========');

    final languages = await getAvailableLanguages();
    debugPrint('\nAvailable Languages (${languages.length}):');
    for (var lang in languages) {
      debugPrint('  - $lang');
    }

    final voices = await getAvailableVoices();
    debugPrint('\nAvailable Voices (${voices.length}):');
    for (var voice in voices) {
      debugPrint('  - ${voice['name']} (${voice['locale']})');
    }

    // Проверка для каждого поддерживаемого языка
    debugPrint('\nSupported Languages Status:');
    final supportedLanguages = ['en', 'ru', 'fr', 'de', 'it', 'my'];
    for (var lang in supportedLanguages) {
      final info = await getLanguageInfo(lang);
      final status = info['hasVoices'] ? '✅' : '❌';
      debugPrint('  $status $lang - Voices: ${info['voices'].length}');
    }

    debugPrint('\n====================================\n');
  }

  /// Тестовая озвучка для языка
  static Future<void> testSpeak(String text, String locale) async {
    try {
      await _tts.setLanguage(locale);
      await _tts.speak(text);
      debugPrint('✅ Speaking in $locale: "$text"');
    } catch (e) {
      debugPrint('❌ Error speaking in $locale: $e');
    }
  }
}
