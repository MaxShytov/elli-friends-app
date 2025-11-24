import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for translating text using Claude API
abstract class TranslationService {
  /// Translate text to all supported languages
  Future<Map<String, String>> translateToAllLanguages({
    required String text,
    required String sourceLanguage,
  });
}

/// Implementation using Claude API
class ClaudeTranslationService implements TranslationService {
  final String apiKey;
  final http.Client? _client;

  static const supportedLanguages = ['en', 'ru', 'fr', 'de', 'it', 'my'];

  static const languageNames = {
    'en': 'English',
    'ru': 'Russian',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'my': 'Burmese (Myanmar)',
  };

  ClaudeTranslationService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client;

  @override
  Future<Map<String, String>> translateToAllLanguages({
    required String text,
    required String sourceLanguage,
  }) async {
    if (text.isEmpty) {
      return {for (final lang in supportedLanguages) lang: ''};
    }

    final client = _client ?? http.Client();

    try {
      debugPrint('[TranslationService] Starting translation...');
      debugPrint('[TranslationService] Source: $sourceLanguage, Text: $text');

      final response = await client.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 2048,
          'messages': [
            {
              'role': 'user',
              'content': _buildPrompt(text, sourceLanguage),
            }
          ]
        }),
      );

      debugPrint('[TranslationService] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[TranslationService] Error body: ${response.body}');
        throw TranslationException(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final content = responseData['content'] as List;

      if (content.isEmpty) {
        throw TranslationException('Empty response from API');
      }

      final textContent = content[0]['text'] as String;
      debugPrint('[TranslationService] Raw response: $textContent');

      final translations = _parseTranslations(textContent, text, sourceLanguage);
      debugPrint('[TranslationService] Parsed translations: $translations');
      return translations;
    } catch (e) {
      if (e is TranslationException) rethrow;
      throw TranslationException('Translation failed: $e');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  String _buildPrompt(String text, String sourceLanguage) {
    final sourceLangName = languageNames[sourceLanguage] ?? sourceLanguage;
    final targetLanguages = supportedLanguages
        .where((lang) => lang != sourceLanguage)
        .map((lang) => '${languageNames[lang]} ($lang)')
        .join(', ');

    return '''You are a translator for a children's educational app about learning to count with friendly animal characters.

Translate this text from $sourceLangName to all target languages.

Source text ($sourceLanguage): "$text"

Target languages: $targetLanguages

Requirements:
1. Keep the tone child-friendly and simple
2. Maintain the same meaning and emotional tone
3. Keep character names unchanged (Orson, Merv, Elli, Bono)
4. Numbers should be translated appropriately
5. Return ONLY valid JSON with no additional text

Return JSON format:
{
  "en": "English translation or original if source is English",
  "ru": "Russian translation",
  "fr": "French translation",
  "de": "German translation",
  "it": "Italian translation",
  "my": "Burmese translation"
}''';
  }

  Map<String, String> _parseTranslations(
    String responseText,
    String originalText,
    String sourceLanguage,
  ) {
    // Try to extract JSON from the response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);

    if (jsonMatch == null) {
      throw TranslationException('Could not find JSON in response');
    }

    try {
      final translations =
          jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      final result = <String, String>{};
      for (final lang in supportedLanguages) {
        if (lang == sourceLanguage) {
          result[lang] = originalText;
        } else {
          result[lang] = translations[lang]?.toString() ?? '';
        }
      }
      return result;
    } catch (e) {
      throw TranslationException('Failed to parse translations: $e');
    }
  }
}

/// Mock translation service for development/testing
class MockTranslationService implements TranslationService {
  @override
  Future<Map<String, String>> translateToAllLanguages({
    required String text,
    required String sourceLanguage,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock translations
    return {
      'en': sourceLanguage == 'en' ? text : '[EN] $text',
      'ru': sourceLanguage == 'ru' ? text : '[RU] $text',
      'fr': sourceLanguage == 'fr' ? text : '[FR] $text',
      'de': sourceLanguage == 'de' ? text : '[DE] $text',
      'it': sourceLanguage == 'it' ? text : '[IT] $text',
      'my': sourceLanguage == 'my' ? text : '[MY] $text',
    };
  }
}

/// Exception for translation errors
class TranslationException implements Exception {
  final String message;
  TranslationException(this.message);

  @override
  String toString() => 'TranslationException: $message';
}

/// Factory for creating translation service based on environment
class TranslationServiceFactory {
  static TranslationService create({String? apiKey}) {
    if (apiKey != null && apiKey.isNotEmpty) {
      return ClaudeTranslationService(apiKey: apiKey);
    }

    // Use mock in development if no API key
    if (kDebugMode) {
      debugPrint('Warning: Using mock translation service (no API key)');
      return MockTranslationService();
    }

    throw TranslationException(
      'No API key provided and not in debug mode',
    );
  }
}
