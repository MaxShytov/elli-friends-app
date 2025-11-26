/// Reference data for Azure TTS valid values
/// This is the foundation for all voice selection UI
///
/// Contains static data about:
/// - Available voices per language with their capabilities
/// - Supported roles for role-play voices
/// - Parameter limits (pitch, rate, styleDegree, volume)
/// - Helper methods for voice selection and validation
class AzureTtsReference {
  // ═══════════════════════════════════════════════════════════════
  // VOICES BY LANGUAGE
  // ═══════════════════════════════════════════════════════════════

  /// Available voices per language code
  /// Key: language code, Value: list of voice info
  static const Map<String, List<AzureVoiceOption>> voicesByLanguage = {
    'en': [
      AzureVoiceOption(
        name: 'en-US-JennyNeural',
        displayName: 'Jenny (Female)',
        gender: 'Female',
        styles: [
          'assistant',
          'chat',
          'customerservice',
          'newscast',
          'angry',
          'cheerful',
          'sad',
          'excited',
          'friendly',
          'terrified',
          'shouting',
          'unfriendly',
          'whispering',
          'hopeful'
        ],
        supportsRole: true,
      ),
      AzureVoiceOption(
        name: 'en-US-GuyNeural',
        displayName: 'Guy (Male)',
        gender: 'Male',
        styles: [
          'newscast',
          'angry',
          'cheerful',
          'sad',
          'excited',
          'friendly',
          'terrified',
          'shouting',
          'unfriendly',
          'whispering'
        ],
        supportsRole: true,
      ),
      AzureVoiceOption(
        name: 'en-US-AriaNeural',
        displayName: 'Aria (Female)',
        gender: 'Female',
        styles: [
          'chat',
          'customerservice',
          'narration-professional',
          'newscast-casual',
          'newscast-formal',
          'cheerful',
          'empathetic',
          'angry',
          'sad',
          'excited',
          'friendly',
          'terrified',
          'shouting',
          'unfriendly',
          'whispering',
          'hopeful'
        ],
        supportsRole: true,
      ),
      AzureVoiceOption(
        name: 'en-US-AnaNeural',
        displayName: 'Ana (Child Female)',
        gender: 'Female',
        styles: [
          'cheerful',
          'sad',
          'angry',
          'fearful',
          'excited',
          'friendly',
          'hopeful'
        ],
        supportsRole: false,
        isChildVoice: true,
      ),
      AzureVoiceOption(
        name: 'en-US-ChristopherNeural',
        displayName: 'Christopher (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'en-US-EricNeural',
        displayName: 'Eric (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'en-US-MichelleNeural',
        displayName: 'Michelle (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'en-US-RogerNeural',
        displayName: 'Roger (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
    ],

    'ru': [
      AzureVoiceOption(
        name: 'ru-RU-SvetlanaNeural',
        displayName: 'Светлана (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'ru-RU-DmitryNeural',
        displayName: 'Дмитрий (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'ru-RU-DariyaNeural',
        displayName: 'Дария (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
    ],

    'de': [
      AzureVoiceOption(
        name: 'de-DE-KatjaNeural',
        displayName: 'Katja (Female)',
        gender: 'Female',
        styles: ['cheerful', 'angry', 'sad'],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'de-DE-ConradNeural',
        displayName: 'Conrad (Male)',
        gender: 'Male',
        styles: ['cheerful'],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'de-DE-GiselaNeural',
        displayName: 'Gisela (Child Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
        isChildVoice: true,
      ),
      AzureVoiceOption(
        name: 'de-DE-KillianNeural',
        displayName: 'Killian (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'de-DE-AmalaNeural',
        displayName: 'Amala (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
    ],

    'fr': [
      AzureVoiceOption(
        name: 'fr-FR-DeniseNeural',
        displayName: 'Denise (Female)',
        gender: 'Female',
        styles: ['cheerful', 'sad'],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'fr-FR-HenriNeural',
        displayName: 'Henri (Male)',
        gender: 'Male',
        styles: ['cheerful', 'sad'],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'fr-FR-EloiseNeural',
        displayName: 'Eloise (Child Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
        isChildVoice: true,
      ),
      AzureVoiceOption(
        name: 'fr-FR-AlainNeural',
        displayName: 'Alain (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'fr-FR-BrigitteNeural',
        displayName: 'Brigitte (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
    ],

    'it': [
      AzureVoiceOption(
        name: 'it-IT-ElsaNeural',
        displayName: 'Elsa (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'it-IT-IsabellaNeural',
        displayName: 'Isabella (Female)',
        gender: 'Female',
        styles: ['cheerful', 'chat'],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'it-IT-DiegoNeural',
        displayName: 'Diego (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'it-IT-GiuseppeNeural',
        displayName: 'Giuseppe (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'it-IT-PierinaNeural',
        displayName: 'Pierina (Child Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
        isChildVoice: true,
      ),
    ],

    // Amharic (Ethiopia) - основной язык Эфиопии
    'am': [
      AzureVoiceOption(
        name: 'am-ET-MekdesNeural',
        displayName: 'Mekdes (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'am-ET-AmehaNeural',
        displayName: 'Ameha (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
    ],

    // Burmese (Myanmar)
    'my': [
      AzureVoiceOption(
        name: 'my-MM-NilarNeural',
        displayName: 'Nilar (Female)',
        gender: 'Female',
        styles: [],
        supportsRole: false,
      ),
      AzureVoiceOption(
        name: 'my-MM-ThihaNeural',
        displayName: 'Thiha (Male)',
        gender: 'Male',
        styles: [],
        supportsRole: false,
      ),
    ],
  };

  // ═══════════════════════════════════════════════════════════════
  // ROLES (for voices that support role-play)
  // ═══════════════════════════════════════════════════════════════

  /// Roles available for voices that support role attribute
  /// Only en-US voices (Jenny, Guy, Aria) support these roles
  static const List<String> supportedRoles = [
    'Girl',
    'Boy',
    'YoungAdultFemale',
    'YoungAdultMale',
    'OlderAdultFemale',
    'OlderAdultMale',
    'SeniorFemale',
    'SeniorMale',
  ];

  /// Role display names for UI
  static const Map<String, String> roleDisplayNames = {
    'Girl': 'Girl',
    'Boy': 'Boy',
    'YoungAdultFemale': 'Young Adult Female',
    'YoungAdultMale': 'Young Adult Male',
    'OlderAdultFemale': 'Older Adult Female',
    'OlderAdultMale': 'Older Adult Male',
    'SeniorFemale': 'Senior Female',
    'SeniorMale': 'Senior Male',
  };

  // ═══════════════════════════════════════════════════════════════
  // PARAMETER LIMITS
  // ═══════════════════════════════════════════════════════════════

  /// Style degree (intensity) limits
  static const double styleDegreeMin = 0.01;
  static const double styleDegreeMax = 2.0;
  static const double styleDegreeDefault = 1.0;

  /// Pitch adjustment limits (in percent)
  static const int pitchMin = -50;
  static const int pitchMax = 50;
  static const int pitchDefault = 0;

  /// Rate (speed) limits
  static const double rateMin = 0.5;
  static const double rateMax = 2.0;
  static const double rateDefault = 1.0;

  /// Volume options for SSML
  static const List<String> volumeOptions = [
    'silent',
    'x-soft',
    'soft',
    'medium',
    'loud',
    'x-loud',
    'default',
  ];

  /// Default volume
  static const String volumeDefault = 'default';

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get voices for a specific language
  /// Returns English voices if language not found
  static List<AzureVoiceOption> getVoicesForLanguage(String languageCode) {
    return voicesByLanguage[languageCode] ?? voicesByLanguage['en']!;
  }

  /// Get voice info by name
  static AzureVoiceOption? getVoiceInfo(String voiceName) {
    for (final voices in voicesByLanguage.values) {
      for (final voice in voices) {
        if (voice.name == voiceName) return voice;
      }
    }
    return null;
  }

  /// Get available styles for a voice
  static List<String> getStylesForVoice(String voiceName) {
    return getVoiceInfo(voiceName)?.styles ?? [];
  }

  /// Check if voice supports roles
  static bool voiceSupportsRole(String voiceName) {
    return getVoiceInfo(voiceName)?.supportsRole ?? false;
  }

  /// Check if voice supports styles
  static bool voiceSupportsStyles(String voiceName) {
    final voice = getVoiceInfo(voiceName);
    return voice != null && voice.styles.isNotEmpty;
  }

  /// Get available languages
  static List<String> get availableLanguages => voicesByLanguage.keys.toList();

  /// Get language name for display
  static String getLanguageDisplayName(String code) {
    const names = {
      'en': 'English',
      'ru': 'Русский',
      'de': 'Deutsch',
      'fr': 'Français',
      'it': 'Italiano',
      'am': 'አማርኛ (Amharic)',
      'my': 'မြန်မာ (Burmese)',
    };
    return names[code] ?? code;
  }

  /// Get language flag emoji for display
  static String getLanguageFlag(String code) {
    const flags = {
      'en': '🇺🇸',
      'ru': '🇷🇺',
      'de': '🇩🇪',
      'fr': '🇫🇷',
      'it': '🇮🇹',
      'am': '🇪🇹',
      'my': '🇲🇲',
    };
    return flags[code] ?? '🌐';
  }

  /// Format pitch value for display (e.g., 5 -> "+5%", -5 -> "-5%")
  static String formatPitch(int pitch) {
    return pitch >= 0 ? '+$pitch%' : '$pitch%';
  }

  /// Parse pitch from string (e.g., "+5%" -> 5)
  static int parsePitch(String pitch) {
    final cleaned = pitch.replaceAll('%', '').replaceAll('+', '');
    return int.tryParse(cleaned) ?? 0;
  }

  /// Format rate value for SSML (e.g., 0.9 -> "-10%", 1.2 -> "+20%")
  static String formatRate(double rate) {
    final percent = ((rate - 1.0) * 100).round();
    return percent >= 0 ? '+$percent%' : '$percent%';
  }

  /// Parse rate from percentage string (e.g., "-10%" -> 0.9)
  static double parseRate(String rateStr) {
    final cleaned = rateStr.replaceAll('%', '').replaceAll('+', '');
    final percent = int.tryParse(cleaned) ?? 0;
    return 1.0 + (percent / 100.0);
  }

  /// Get default voice for language and character type
  static String getDefaultVoice(
    String languageCode, {
    bool isChild = false,
    bool isMale = false,
  }) {
    final voices = getVoicesForLanguage(languageCode);

    // Try to find matching voice
    for (final voice in voices) {
      if (isChild && voice.isChildVoice) return voice.name;
      if (!isChild &&
          voice.gender == (isMale ? 'Male' : 'Female') &&
          !voice.isChildVoice) {
        return voice.name;
      }
    }

    // Fallback to first voice
    return voices.first.name;
  }

  /// Get locale from voice name (e.g., "en-US-JennyNeural" -> "en-US")
  static String getLocaleFromVoice(String voiceName) {
    // Voice names are formatted as "xx-XX-NameNeural"
    // Extract the first 5 characters for locale
    if (voiceName.length >= 5) {
      return voiceName.substring(0, 5);
    }
    return 'en-US';
  }

  /// Get language code from voice name (e.g., "en-US-JennyNeural" -> "en")
  static String getLanguageCodeFromVoice(String voiceName) {
    if (voiceName.length >= 2) {
      return voiceName.substring(0, 2);
    }
    return 'en';
  }

  /// Validate style for a specific voice
  static bool isStyleValidForVoice(String voiceName, String style) {
    final voice = getVoiceInfo(voiceName);
    if (voice == null) return false;
    return voice.styles.contains(style);
  }

  /// Get common styles available across multiple voices
  /// Useful for UI to show only styles that work for character's voice
  static List<String> getCommonStyles() {
    return [
      'cheerful',
      'friendly',
      'excited',
      'sad',
      'angry',
    ];
  }

  /// Style display names for UI
  static String getStyleDisplayName(String style) {
    const names = {
      'assistant': 'Assistant',
      'chat': 'Chat',
      'customerservice': 'Customer Service',
      'newscast': 'Newscast',
      'newscast-casual': 'Newscast Casual',
      'newscast-formal': 'Newscast Formal',
      'narration-professional': 'Professional Narration',
      'angry': 'Angry',
      'cheerful': 'Cheerful',
      'sad': 'Sad',
      'excited': 'Excited',
      'friendly': 'Friendly',
      'terrified': 'Terrified',
      'shouting': 'Shouting',
      'unfriendly': 'Unfriendly',
      'whispering': 'Whispering',
      'hopeful': 'Hopeful',
      'empathetic': 'Empathetic',
      'fearful': 'Fearful',
    };
    // Capitalize first letter if not in map
    return names[style] ??
        style.replaceFirst(style[0], style[0].toUpperCase());
  }
}

/// Information about an Azure TTS voice
class AzureVoiceOption {
  /// Full voice name (e.g., "en-US-JennyNeural")
  final String name;

  /// Display name for UI (e.g., "Jenny (Female)")
  final String displayName;

  /// Gender: "Female" or "Male"
  final String gender;

  /// List of supported emotional styles (empty if none)
  final List<String> styles;

  /// Whether this voice supports role attribute
  final bool supportsRole;

  /// Whether this is a child voice
  final bool isChildVoice;

  const AzureVoiceOption({
    required this.name,
    required this.displayName,
    required this.gender,
    this.styles = const [],
    this.supportsRole = false,
    this.isChildVoice = false,
  });

  /// Whether this voice has any styles
  bool get hasStyles => styles.isNotEmpty;

  /// Get locale from voice name
  String get locale => AzureTtsReference.getLocaleFromVoice(name);

  /// Get language code from voice name
  String get languageCode => AzureTtsReference.getLanguageCodeFromVoice(name);

  @override
  String toString() => 'AzureVoiceOption($name, styles: ${styles.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AzureVoiceOption &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
