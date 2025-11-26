import '../../../../core/services/azure_tts_reference.dart';

/// Voice profile for a character in a specific language
///
/// This represents the "actor" level settings - the base voice configuration
/// for a character. Each character has one profile PER language.
///
/// Example usage:
/// ```dart
/// final elliProfile = CharacterVoiceProfile(
///   characterId: 'elli',
///   languageCode: 'en',
///   voiceName: 'en-US-JennyNeural',
///   role: 'Girl',
///   basePitch: '+8%',
///   baseRate: 1.0,
///   defaultStyle: 'cheerful',
///   defaultStyleDegree: 1.1,
/// );
/// ```
class CharacterVoiceProfile {
  /// Character identifier (e.g., "orson", "elli", "bono")
  final String characterId;

  /// Language code (e.g., "en", "ru", "de")
  final String languageCode;

  /// Azure voice name (e.g., "en-US-JennyNeural")
  final String voiceName;

  /// Azure role for role-play voices (e.g., "Girl", "Boy", "OlderAdultMale")
  /// Only applicable for voices that support role attribute
  final String? role;

  /// Base pitch adjustment (e.g., "+8%", "-5%", "0%")
  final String basePitch;

  /// Base speech rate (0.5 - 2.0, where 1.0 is normal speed)
  final double baseRate;

  /// Default emotional style (e.g., "cheerful", "friendly", "excited")
  /// Only applicable for voices that support styles
  final String? defaultStyle;

  /// Default style intensity (0.01 - 2.0, where 1.0 is normal)
  final double defaultStyleDegree;

  const CharacterVoiceProfile({
    required this.characterId,
    required this.languageCode,
    required this.voiceName,
    this.role,
    this.basePitch = '0%',
    this.baseRate = 1.0,
    this.defaultStyle,
    this.defaultStyleDegree = 1.0,
  });

  // ═══════════════════════════════════════════════════════════════
  // VOICE INFO ACCESSORS
  // ═══════════════════════════════════════════════════════════════

  /// Get voice info from reference data
  AzureVoiceOption? get voiceInfo => AzureTtsReference.getVoiceInfo(voiceName);

  /// Check if this voice supports styles
  bool get supportsStyles => voiceInfo?.hasStyles ?? false;

  /// Check if this voice supports roles
  bool get supportsRole => voiceInfo?.supportsRole ?? false;

  /// Get available styles for this voice
  List<String> get availableStyles => voiceInfo?.styles ?? [];

  /// Get the locale from voice name (e.g., "en-US")
  String get locale => AzureTtsReference.getLocaleFromVoice(voiceName);

  /// Check if voice is a child voice
  bool get isChildVoice => voiceInfo?.isChildVoice ?? false;

  /// Get voice gender
  String? get gender => voiceInfo?.gender;

  // ═══════════════════════════════════════════════════════════════
  // PARAMETER COMBINATION METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Combine base pitch with a modifier from DialogueVoiceContext
  ///
  /// Example: basePitch "+8%" + modifier "+5%" = "+13%"
  String combinePitch(String? modifier) {
    if (modifier == null || modifier.isEmpty) return basePitch;

    final baseValue = AzureTtsReference.parsePitch(basePitch);
    final modValue = AzureTtsReference.parsePitch(modifier);
    final combined = (baseValue + modValue).clamp(
      AzureTtsReference.pitchMin,
      AzureTtsReference.pitchMax,
    );

    return AzureTtsReference.formatPitch(combined);
  }

  /// Combine base rate with a modifier (multiplicative)
  ///
  /// Example: baseRate 0.9 * modifier 1.1 = 0.99
  double combineRate(double? modifier) {
    if (modifier == null) return baseRate;
    return (baseRate * modifier).clamp(
      AzureTtsReference.rateMin,
      AzureTtsReference.rateMax,
    );
  }

  /// Get effective style (from profile or context)
  String? getEffectiveStyle(String? contextStyle) {
    if (!supportsStyles) return null;
    return contextStyle ?? defaultStyle;
  }

  /// Get effective style degree
  double getEffectiveStyleDegree(double? contextStyleDegree) {
    return contextStyleDegree ?? defaultStyleDegree;
  }

  // ═══════════════════════════════════════════════════════════════
  // COPY AND SERIALIZATION
  // ═══════════════════════════════════════════════════════════════

  /// Create a copy with updated values
  CharacterVoiceProfile copyWith({
    String? characterId,
    String? languageCode,
    String? voiceName,
    String? role,
    String? basePitch,
    double? baseRate,
    String? defaultStyle,
    double? defaultStyleDegree,
  }) {
    return CharacterVoiceProfile(
      characterId: characterId ?? this.characterId,
      languageCode: languageCode ?? this.languageCode,
      voiceName: voiceName ?? this.voiceName,
      role: role ?? this.role,
      basePitch: basePitch ?? this.basePitch,
      baseRate: baseRate ?? this.baseRate,
      defaultStyle: defaultStyle ?? this.defaultStyle,
      defaultStyleDegree: defaultStyleDegree ?? this.defaultStyleDegree,
    );
  }

  /// Create a copy with role cleared (set to null)
  CharacterVoiceProfile clearRole() {
    return CharacterVoiceProfile(
      characterId: characterId,
      languageCode: languageCode,
      voiceName: voiceName,
      role: null,
      basePitch: basePitch,
      baseRate: baseRate,
      defaultStyle: defaultStyle,
      defaultStyleDegree: defaultStyleDegree,
    );
  }

  /// Create a copy with style cleared (set to null)
  CharacterVoiceProfile clearStyle() {
    return CharacterVoiceProfile(
      characterId: characterId,
      languageCode: languageCode,
      voiceName: voiceName,
      role: role,
      basePitch: basePitch,
      baseRate: baseRate,
      defaultStyle: null,
      defaultStyleDegree: defaultStyleDegree,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'characterId': characterId,
        'languageCode': languageCode,
        'voiceName': voiceName,
        'role': role,
        'basePitch': basePitch,
        'baseRate': baseRate,
        'defaultStyle': defaultStyle,
        'defaultStyleDegree': defaultStyleDegree,
      };

  /// Create from JSON map
  factory CharacterVoiceProfile.fromJson(Map<String, dynamic> json) {
    return CharacterVoiceProfile(
      characterId: json['characterId'] as String,
      languageCode: json['languageCode'] as String,
      voiceName: json['voiceName'] as String,
      role: json['role'] as String?,
      basePitch: json['basePitch'] as String? ?? '0%',
      baseRate: (json['baseRate'] as num?)?.toDouble() ?? 1.0,
      defaultStyle: json['defaultStyle'] as String?,
      defaultStyleDegree:
          (json['defaultStyleDegree'] as num?)?.toDouble() ?? 1.0,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS
  // ═══════════════════════════════════════════════════════════════

  /// Create default profile for a character and language
  ///
  /// Automatically selects appropriate voice based on character type
  factory CharacterVoiceProfile.defaultFor({
    required String characterId,
    required String languageCode,
    bool isChild = false,
    bool isMale = false,
  }) {
    final voiceName = AzureTtsReference.getDefaultVoice(
      languageCode,
      isChild: isChild,
      isMale: isMale,
    );
    final voiceInfo = AzureTtsReference.getVoiceInfo(voiceName);

    return CharacterVoiceProfile(
      characterId: characterId,
      languageCode: languageCode,
      voiceName: voiceName,
      defaultStyle: voiceInfo?.hasStyles == true ? 'friendly' : null,
    );
  }

  /// Create profile from voice-only JSON (without characterId/languageCode)
  /// Used when loading from database where these are stored separately
  factory CharacterVoiceProfile.fromVoiceJson({
    required String characterId,
    required String languageCode,
    required Map<String, dynamic> json,
  }) {
    // Handle basePitch as either int or string
    String basePitch;
    final rawPitch = json['basePitch'];
    if (rawPitch is int) {
      basePitch = rawPitch >= 0 ? '+$rawPitch%' : '$rawPitch%';
    } else {
      basePitch = rawPitch as String? ?? '0%';
    }

    return CharacterVoiceProfile(
      characterId: characterId,
      languageCode: languageCode,
      voiceName: json['voiceName'] as String,
      role: json['role'] as String?,
      basePitch: basePitch,
      baseRate: (json['baseRate'] as num?)?.toDouble() ?? 1.0,
      defaultStyle: json['defaultStyle'] as String?,
      defaultStyleDegree:
          (json['defaultStyleDegree'] as num?)?.toDouble() ?? 1.0,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EQUALITY AND STRING REPRESENTATION
  // ═══════════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterVoiceProfile &&
          runtimeType == other.runtimeType &&
          characterId == other.characterId &&
          languageCode == other.languageCode &&
          voiceName == other.voiceName &&
          role == other.role &&
          basePitch == other.basePitch &&
          baseRate == other.baseRate &&
          defaultStyle == other.defaultStyle &&
          defaultStyleDegree == other.defaultStyleDegree;

  @override
  int get hashCode => Object.hash(
        characterId,
        languageCode,
        voiceName,
        role,
        basePitch,
        baseRate,
        defaultStyle,
        defaultStyleDegree,
      );

  @override
  String toString() {
    return 'CharacterVoiceProfile('
        'characterId: $characterId, '
        'languageCode: $languageCode, '
        'voiceName: $voiceName, '
        'role: $role, '
        'basePitch: $basePitch, '
        'baseRate: $baseRate, '
        'defaultStyle: $defaultStyle, '
        'defaultStyleDegree: $defaultStyleDegree)';
  }
}
