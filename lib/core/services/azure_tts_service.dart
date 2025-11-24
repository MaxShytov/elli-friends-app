import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Configuration for Azure TTS voice mapping per character and language
class AzureTtsConfig {
  /// Azure TTS voices mapped by character and language code
  ///
  /// Character voices are selected to match their personalities:
  /// - orson: Male voice - wise lion
  /// - merv: Male voice - magical wizard (slightly higher pitch)
  /// - elli: Female voice - friendly elephant
  /// - bono: Child voice - elephant helper
  /// - hippo: Female voice - cheerful hippo
  static const Map<String, Map<String, String>> characterVoices = {
    'orson': {
      'en': 'en-US-GuyNeural',
      'ru': 'ru-RU-DmitryNeural',
      'fr': 'fr-FR-HenriNeural',
      'de': 'de-DE-ConradNeural',
      'it': 'it-IT-DiegoNeural',
      'my': 'my-MM-ThihaNeural',
      'am': 'am-ET-AmehaNeural',
    },
    'merv': {
      'en': 'en-US-ChristopherNeural',
      'ru': 'ru-RU-DmitryNeural',
      'fr': 'fr-FR-AlainNeural',
      'de': 'de-DE-KillianNeural',
      'it': 'it-IT-GiuseppeNeural',
      'my': 'my-MM-ThihaNeural',
      'am': 'am-ET-AmehaNeural',
    },
    'elli': {
      'en': 'en-US-JennyNeural',
      'ru': 'ru-RU-SvetlanaNeural',
      'fr': 'fr-FR-DeniseNeural',
      'de': 'de-DE-KatjaNeural',
      'it': 'it-IT-ElsaNeural',
      'my': 'my-MM-NilarNeural',
      'am': 'am-ET-MekdesNeural',
    },
    'bono': {
      'en': 'en-US-AnaNeural', // Child voice
      'ru': 'ru-RU-DariyaNeural',
      'fr': 'fr-FR-EloiseNeural',
      'de': 'de-DE-GiselaNeural',
      'it': 'it-IT-PierinaNeural',
      'my': 'my-MM-NilarNeural',
      'am': 'am-ET-MekdesNeural',
    },
    'hippo': {
      'en': 'en-US-AriaNeural',
      'ru': 'ru-RU-SvetlanaNeural',
      'fr': 'fr-FR-DeniseNeural',
      'de': 'de-DE-KatjaNeural',
      'it': 'it-IT-IsabellaNeural',
      'my': 'my-MM-NilarNeural',
      'am': 'am-ET-MekdesNeural',
    },
  };

  /// Supported Azure regions
  static const List<String> supportedRegions = [
    'eastus',
    'westus',
    'westus2',
    'westeurope',
    'northeurope',
    'southeastasia',
    'eastasia',
    'australiaeast',
  ];

  /// Default region
  static const String defaultRegion = 'eastus';

  /// Get voice name for character and language
  static String getVoice(String character, String languageCode) {
    final characterLower = character.toLowerCase();
    final voices = characterVoices[characterLower];

    if (voices == null) {
      // Default to bono if character not found
      return characterVoices['bono']![languageCode] ??
             characterVoices['bono']!['en']!;
    }

    return voices[languageCode] ?? voices['en'] ?? 'en-US-JennyNeural';
  }

  /// Get Azure locale code from app language code
  static String getAzureLocale(String languageCode) {
    const localeMapping = {
      'en': 'en-US',
      'ru': 'ru-RU',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'my': 'my-MM',
      'am': 'am-ET',
    };
    return localeMapping[languageCode] ?? 'en-US';
  }
}

/// Service for generating speech audio using Azure Cognitive Services TTS
class AzureTtsService {
  final String subscriptionKey;
  final String region;
  final http.Client _httpClient;

  AzureTtsService({
    required this.subscriptionKey,
    this.region = AzureTtsConfig.defaultRegion,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Azure TTS endpoint URL
  String get _endpoint =>
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1';

  /// Generate audio for text with specified character voice
  ///
  /// Returns MP3 audio data as Uint8List
  /// Throws [AzureTtsException] on failure
  Future<Uint8List> generateAudio({
    required String text,
    required String languageCode,
    required String character,
    String? emotion,
    double rate = 0.9, // Speech rate (0.5 - 2.0, default slower for kids)
    double pitch = 0.0, // Pitch adjustment (-50% to +50%)
  }) async {
    if (text.trim().isEmpty) {
      throw AzureTtsException('Text cannot be empty');
    }

    final voiceName = AzureTtsConfig.getVoice(character, languageCode);
    final locale = AzureTtsConfig.getAzureLocale(languageCode);

    // Build SSML with emotion and prosody
    final ssml = _buildSsml(
      text: text,
      voiceName: voiceName,
      locale: locale,
      emotion: emotion,
      rate: rate,
      pitch: pitch,
    );

    debugPrint('Azure TTS: Generating audio for "$text" with voice $voiceName');

    try {
      final response = await _httpClient.post(
        Uri.parse(_endpoint),
        headers: {
          'Ocp-Apim-Subscription-Key': subscriptionKey,
          'Content-Type': 'application/ssml+xml',
          'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
          'User-Agent': 'ElliFriendsApp',
        },
        body: ssml,
      );

      if (response.statusCode == 200) {
        debugPrint('Azure TTS: Successfully generated ${response.bodyBytes.length} bytes');
        return response.bodyBytes;
      } else {
        final errorBody = response.body;
        debugPrint('Azure TTS Error: ${response.statusCode} - $errorBody');
        throw AzureTtsException(
          'Failed to generate audio: ${response.statusCode}',
          statusCode: response.statusCode,
          details: errorBody,
        );
      }
    } catch (e) {
      if (e is AzureTtsException) rethrow;
      throw AzureTtsException('Network error: $e');
    }
  }

  /// Build SSML (Speech Synthesis Markup Language) for Azure TTS
  String _buildSsml({
    required String text,
    required String voiceName,
    required String locale,
    String? emotion,
    double rate = 1.0,
    double pitch = 0.0,
  }) {
    // Escape XML special characters
    final escapedText = _escapeXml(text);

    // Convert rate to percentage (0.9 -> -10%)
    final ratePercent = ((rate - 1.0) * 100).round();
    final rateStr = ratePercent >= 0 ? '+$ratePercent%' : '$ratePercent%';

    // Pitch adjustment
    final pitchStr = pitch >= 0 ? '+${pitch.round()}%' : '${pitch.round()}%';

    // Build express-as style if emotion is specified
    String contentWithEmotion;
    if (emotion != null && _isEmotionSupported(voiceName, emotion)) {
      final azureStyle = _mapEmotionToAzureStyle(emotion);
      contentWithEmotion = '''
        <mstts:express-as style="$azureStyle">
          <prosody rate="$rateStr" pitch="$pitchStr">$escapedText</prosody>
        </mstts:express-as>''';
    } else {
      contentWithEmotion = '''
        <prosody rate="$rateStr" pitch="$pitchStr">$escapedText</prosody>''';
    }

    return '''<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xmlns:mstts='http://www.w3.org/2001/mstts' xml:lang='$locale'>
  <voice name='$voiceName'>$contentWithEmotion
  </voice>
</speak>''';
  }

  /// Escape XML special characters
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Map app emotion to Azure TTS style
  String _mapEmotionToAzureStyle(String emotion) {
    const emotionMapping = {
      'Happy': 'cheerful',
      'Sad': 'sad',
      'Angry': 'angry',
      'Excited': 'excited',
      'Friendly': 'friendly',
      'Neutral': 'neutral',
      'Gentle': 'gentle',
      'Eating': 'cheerful', // No direct mapping
      'Intense Sad': 'sad',
    };
    return emotionMapping[emotion] ?? 'friendly';
  }

  /// Check if emotion style is supported for the voice
  bool _isEmotionSupported(String voiceName, String emotion) {
    // Azure Neural voices with style support
    // Most en-US Neural voices support styles
    const voicesWithStyleSupport = [
      'en-US-JennyNeural',
      'en-US-GuyNeural',
      'en-US-AriaNeural',
      'en-US-AnaNeural',
    ];
    return voicesWithStyleSupport.contains(voiceName);
  }

  /// Test connection to Azure TTS
  Future<bool> testConnection() async {
    try {
      final audio = await generateAudio(
        text: 'Test',
        languageCode: 'en',
        character: 'bono',
      );
      return audio.isNotEmpty;
    } catch (e) {
      debugPrint('Azure TTS connection test failed: $e');
      return false;
    }
  }

  /// Get list of available voices for a language
  Future<List<AzureVoiceInfo>> getAvailableVoices(String languageCode) async {
    final locale = AzureTtsConfig.getAzureLocale(languageCode);
    final listUrl = 'https://$region.tts.speech.microsoft.com/cognitiveservices/voices/list';

    try {
      final response = await _httpClient.get(
        Uri.parse(listUrl),
        headers: {
          'Ocp-Apim-Subscription-Key': subscriptionKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> voicesJson = json.decode(response.body);
        return voicesJson
            .where((v) => (v['Locale'] as String).startsWith(locale.split('-')[0]))
            .map((v) => AzureVoiceInfo.fromJson(v))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get voices: $e');
      return [];
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Information about an Azure TTS voice
class AzureVoiceInfo {
  final String name;
  final String displayName;
  final String locale;
  final String gender;
  final List<String> styleList;

  AzureVoiceInfo({
    required this.name,
    required this.displayName,
    required this.locale,
    required this.gender,
    this.styleList = const [],
  });

  factory AzureVoiceInfo.fromJson(Map<String, dynamic> json) {
    return AzureVoiceInfo(
      name: json['ShortName'] as String,
      displayName: json['DisplayName'] as String,
      locale: json['Locale'] as String,
      gender: json['Gender'] as String,
      styleList: (json['StyleList'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
    );
  }
}

/// Exception thrown by Azure TTS service
class AzureTtsException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  AzureTtsException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AzureTtsException: $message (HTTP $statusCode)';
    }
    return 'AzureTtsException: $message';
  }
}
