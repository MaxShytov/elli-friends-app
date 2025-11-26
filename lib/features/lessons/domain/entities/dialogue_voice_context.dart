import '../../../../core/services/azure_tts_reference.dart';

/// Voice context for a specific dialogue line (Scene level settings)
///
/// This represents the "phrase" level settings - the emotional and prosodic
/// adjustments for a specific line of dialogue. These parameters change
/// based on the emotional context of the scene.
///
/// The values in DialogueVoiceContext are MODIFIERS that are combined
/// with CharacterVoiceProfile base settings:
/// - pitch: added to base pitch
/// - rate: multiplied with base rate
/// - style: overrides default style (if voice supports styles)
///
/// Example usage:
/// ```dart
/// final excitedContext = DialogueVoiceContext(
///   style: 'excited',
///   styleDegree: 1.3,
///   pitchModifier: '+5%',
///   rateModifier: 1.1,
/// );
/// ```
class DialogueVoiceContext {
  /// Emotion style (e.g., "cheerful", "excited", "sad", "angry")
  /// Only applies to voices that support styles
  final String? style;

  /// Style intensity (0.01 - 2.0, where 1.0 is normal)
  /// Higher values = more expressive emotion
  final double? styleDegree;

  /// Pitch adjustment modifier (e.g., "+10%", "-5%")
  /// This is ADDED to the character's base pitch
  final String? pitchModifier;

  /// Rate adjustment modifier (e.g., 0.8, 1.2)
  /// This is MULTIPLIED with the character's base rate
  final double? rateModifier;

  /// Volume level (e.g., "soft", "medium", "loud", "x-loud")
  final String? volume;

  /// Words to emphasize in the text
  final List<String>? emphasisWords;

  /// Pause before speaking in milliseconds
  final int? breakBefore;

  /// Pause after speaking in milliseconds
  final int? breakAfter;

  const DialogueVoiceContext({
    this.style,
    this.styleDegree,
    this.pitchModifier,
    this.rateModifier,
    this.volume,
    this.emphasisWords,
    this.breakBefore,
    this.breakAfter,
  });

  // ═══════════════════════════════════════════════════════════════
  // FACTORY CONSTRUCTORS FOR COMMON EMOTIONS
  // ═══════════════════════════════════════════════════════════════

  /// Empty context (no modifications)
  static const DialogueVoiceContext empty = DialogueVoiceContext();

  /// Create context for excited speech
  factory DialogueVoiceContext.excited({double intensity = 1.3}) {
    return DialogueVoiceContext(
      style: 'excited',
      styleDegree: intensity,
      pitchModifier: '+5%',
      rateModifier: 1.1,
    );
  }

  /// Create context for cheerful speech
  factory DialogueVoiceContext.cheerful({double intensity = 1.2}) {
    return DialogueVoiceContext(
      style: 'cheerful',
      styleDegree: intensity,
    );
  }

  /// Create context for sad speech
  factory DialogueVoiceContext.sad({double intensity = 1.2}) {
    return DialogueVoiceContext(
      style: 'sad',
      styleDegree: intensity,
      pitchModifier: '-5%',
      rateModifier: 0.85,
    );
  }

  /// Create context for angry speech
  factory DialogueVoiceContext.angry({double intensity = 1.3}) {
    return DialogueVoiceContext(
      style: 'angry',
      styleDegree: intensity,
      pitchModifier: '+3%',
      rateModifier: 1.1,
    );
  }

  /// Create context for calm/gentle speech
  factory DialogueVoiceContext.calm() {
    return const DialogueVoiceContext(
      style: 'friendly',
      rateModifier: 0.9,
      volume: 'soft',
    );
  }

  /// Create context for whispering
  factory DialogueVoiceContext.whisper() {
    return const DialogueVoiceContext(
      style: 'whispering',
      volume: 'x-soft',
      rateModifier: 0.85,
    );
  }

  /// Create context for shouting
  factory DialogueVoiceContext.shout() {
    return const DialogueVoiceContext(
      style: 'shouting',
      volume: 'x-loud',
      pitchModifier: '+10%',
      rateModifier: 1.15,
    );
  }

  /// Create context for questioning tone
  factory DialogueVoiceContext.questioning() {
    return const DialogueVoiceContext(
      style: 'friendly',
      pitchModifier: '+10%',
      breakAfter: 500,
    );
  }

  /// Create context for clear/explaining speech (teacher mode)
  factory DialogueVoiceContext.clear() {
    return const DialogueVoiceContext(
      style: 'friendly',
      styleDegree: 1.0,
      rateModifier: 0.92,
      breakAfter: 300,
    );
  }

  /// Create context for amazed/wow speech
  factory DialogueVoiceContext.amazed({double intensity = 1.4}) {
    return DialogueVoiceContext(
      style: 'excited',
      styleDegree: intensity,
      pitchModifier: '+8%',
      rateModifier: 0.95,
    );
  }

  /// Create context for counting numbers (slow, clear)
  factory DialogueVoiceContext.counting() {
    return const DialogueVoiceContext(
      style: 'cheerful',
      styleDegree: 1.1,
      rateModifier: 0.80,
      breakAfter: 200,
    );
  }

  /// Create context for enthusiastic/praise speech
  factory DialogueVoiceContext.enthusiastic({double intensity = 1.4}) {
    return DialogueVoiceContext(
      style: 'excited',
      styleDegree: intensity,
      pitchModifier: '+7%',
      rateModifier: 1.05,
    );
  }

  /// Create context for proud speech (praising child)
  factory DialogueVoiceContext.proud({double intensity = 1.3}) {
    return DialogueVoiceContext(
      style: 'cheerful',
      styleDegree: intensity,
      pitchModifier: '+3%',
      rateModifier: 0.95,
    );
  }

  /// Create context for grateful/thankful speech
  factory DialogueVoiceContext.grateful({double intensity = 1.2}) {
    return DialogueVoiceContext(
      style: 'friendly',
      styleDegree: intensity,
      rateModifier: 0.9,
      volume: 'medium',
    );
  }

  /// Create context for mysterious/magical speech
  factory DialogueVoiceContext.mysterious({double intensity = 1.3}) {
    return DialogueVoiceContext(
      style: 'whispering',
      styleDegree: intensity,
      pitchModifier: '-3%',
      rateModifier: 0.85,
      volume: 'soft',
    );
  }

  /// Create context for inviting/welcoming speech
  factory DialogueVoiceContext.inviting({double intensity = 1.2}) {
    return DialogueVoiceContext(
      style: 'friendly',
      styleDegree: intensity,
      pitchModifier: '+5%',
      rateModifier: 0.95,
    );
  }

  /// Create context for surprised speech
  factory DialogueVoiceContext.surprised({double intensity = 1.4}) {
    return DialogueVoiceContext(
      style: 'excited',
      styleDegree: intensity,
      pitchModifier: '+12%',
      rateModifier: 1.1,
      breakBefore: 100,
    );
  }

  /// Create context for thoughtful/thinking speech
  factory DialogueVoiceContext.thoughtful() {
    return const DialogueVoiceContext(
      style: 'friendly',
      styleDegree: 0.9,
      rateModifier: 0.85,
      breakBefore: 300,
      breakAfter: 200,
    );
  }

  /// Create context for explaining speech (step by step)
  factory DialogueVoiceContext.explaining() {
    return const DialogueVoiceContext(
      style: 'friendly',
      styleDegree: 1.0,
      rateModifier: 0.88,
      breakAfter: 400,
    );
  }

  /// Create context for playful speech
  factory DialogueVoiceContext.playful({double intensity = 1.3}) {
    return DialogueVoiceContext(
      style: 'cheerful',
      styleDegree: intensity,
      pitchModifier: '+5%',
      rateModifier: 1.05,
    );
  }

  /// Create from scene tone string (legacy support)
  ///
  /// Maps old-style tone strings to appropriate voice context
  factory DialogueVoiceContext.fromTone(String? tone) {
    if (tone == null || tone.isEmpty) return const DialogueVoiceContext();

    switch (tone.toLowerCase()) {
      case 'excited':
        return DialogueVoiceContext.excited();
      case 'cheerful':
      case 'happy':
        return DialogueVoiceContext.cheerful();
      case 'sad':
        return DialogueVoiceContext.sad();
      case 'angry':
        return DialogueVoiceContext.angry();
      case 'calm':
      case 'gentle':
        return DialogueVoiceContext.calm();
      case 'questioning':
      case 'curious':
        return DialogueVoiceContext.questioning();
      case 'whisper':
      case 'whispering':
        return DialogueVoiceContext.whisper();
      case 'shout':
      case 'shouting':
        return DialogueVoiceContext.shout();
      case 'friendly':
        return const DialogueVoiceContext(style: 'friendly');
      case 'neutral':
        return const DialogueVoiceContext();
      // New tones for lessons
      case 'clear':
        return DialogueVoiceContext.clear();
      case 'amazed':
        return DialogueVoiceContext.amazed();
      case 'counting':
        return DialogueVoiceContext.counting();
      case 'enthusiastic':
        return DialogueVoiceContext.enthusiastic();
      case 'proud':
        return DialogueVoiceContext.proud();
      case 'grateful':
        return DialogueVoiceContext.grateful();
      case 'mysterious':
        return DialogueVoiceContext.mysterious();
      case 'inviting':
        return DialogueVoiceContext.inviting();
      case 'surprised':
        return DialogueVoiceContext.surprised();
      case 'thoughtful':
        return DialogueVoiceContext.thoughtful();
      case 'explaining':
        return DialogueVoiceContext.explaining();
      case 'playful':
        return DialogueVoiceContext.playful();
      default:
        // Try to use the tone as a style directly
        if (AzureTtsReference.getCommonStyles().contains(tone.toLowerCase())) {
          return DialogueVoiceContext(style: tone.toLowerCase());
        }
        return const DialogueVoiceContext(style: 'friendly');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STATE CHECKS
  // ═══════════════════════════════════════════════════════════════

  /// Whether this context has any modifications
  bool get hasContext =>
      style != null ||
      styleDegree != null ||
      pitchModifier != null ||
      rateModifier != null ||
      volume != null ||
      (emphasisWords != null && emphasisWords!.isNotEmpty) ||
      breakBefore != null ||
      breakAfter != null;

  /// Whether this context has style settings
  bool get hasStyle => style != null || styleDegree != null;

  /// Whether this context has prosody settings
  bool get hasProsody =>
      pitchModifier != null || rateModifier != null || volume != null;

  /// Whether this context has break/pause settings
  bool get hasBreaks => breakBefore != null || breakAfter != null;

  // ═══════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════

  /// Validate that style is supported by a voice
  bool isStyleValidFor(String voiceName) {
    if (style == null) return true;
    return AzureTtsReference.isStyleValidForVoice(voiceName, style!);
  }

  /// Get a validated copy - removes style if not supported by voice
  DialogueVoiceContext validatedFor(String voiceName) {
    if (style == null || isStyleValidFor(voiceName)) {
      return this;
    }
    // Style not supported, remove it
    return copyWith(clearStyle: true);
  }

  // ═══════════════════════════════════════════════════════════════
  // COPY AND MERGE
  // ═══════════════════════════════════════════════════════════════

  /// Create a copy with updated values
  ///
  /// Use `clearStyle: true` to set style to null
  /// Use `clearPitch: true` to set pitchModifier to null
  DialogueVoiceContext copyWith({
    String? style,
    double? styleDegree,
    String? pitchModifier,
    double? rateModifier,
    String? volume,
    List<String>? emphasisWords,
    int? breakBefore,
    int? breakAfter,
    bool clearStyle = false,
    bool clearPitch = false,
    bool clearRate = false,
    bool clearVolume = false,
  }) {
    return DialogueVoiceContext(
      style: clearStyle ? null : (style ?? this.style),
      styleDegree: clearStyle ? null : (styleDegree ?? this.styleDegree),
      pitchModifier: clearPitch ? null : (pitchModifier ?? this.pitchModifier),
      rateModifier: clearRate ? null : (rateModifier ?? this.rateModifier),
      volume: clearVolume ? null : (volume ?? this.volume),
      emphasisWords: emphasisWords ?? this.emphasisWords,
      breakBefore: breakBefore ?? this.breakBefore,
      breakAfter: breakAfter ?? this.breakAfter,
    );
  }

  /// Merge with another context (other takes priority)
  DialogueVoiceContext merge(DialogueVoiceContext? other) {
    if (other == null) return this;
    return DialogueVoiceContext(
      style: other.style ?? style,
      styleDegree: other.styleDegree ?? styleDegree,
      pitchModifier: other.pitchModifier ?? pitchModifier,
      rateModifier: other.rateModifier ?? rateModifier,
      volume: other.volume ?? volume,
      emphasisWords: other.emphasisWords ?? emphasisWords,
      breakBefore: other.breakBefore ?? breakBefore,
      breakAfter: other.breakAfter ?? breakAfter,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZATION
  // ═══════════════════════════════════════════════════════════════

  /// Convert to JSON map (only includes non-null values)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (style != null) json['style'] = style;
    if (styleDegree != null) json['styleDegree'] = styleDegree;
    if (pitchModifier != null) json['pitchModifier'] = pitchModifier;
    if (rateModifier != null) json['rateModifier'] = rateModifier;
    if (volume != null) json['volume'] = volume;
    if (emphasisWords != null && emphasisWords!.isNotEmpty) {
      json['emphasisWords'] = emphasisWords;
    }
    if (breakBefore != null) json['breakBefore'] = breakBefore;
    if (breakAfter != null) json['breakAfter'] = breakAfter;
    return json;
  }

  /// Create from JSON map
  factory DialogueVoiceContext.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const DialogueVoiceContext();
    return DialogueVoiceContext(
      style: json['style'] as String?,
      styleDegree: (json['styleDegree'] as num?)?.toDouble(),
      pitchModifier: json['pitchModifier'] as String?,
      rateModifier: (json['rateModifier'] as num?)?.toDouble(),
      volume: json['volume'] as String?,
      emphasisWords: (json['emphasisWords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      breakBefore: json['breakBefore'] as int?,
      breakAfter: json['breakAfter'] as int?,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EQUALITY AND STRING REPRESENTATION
  // ═══════════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogueVoiceContext &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          styleDegree == other.styleDegree &&
          pitchModifier == other.pitchModifier &&
          rateModifier == other.rateModifier &&
          volume == other.volume &&
          _listEquals(emphasisWords, other.emphasisWords) &&
          breakBefore == other.breakBefore &&
          breakAfter == other.breakAfter;

  @override
  int get hashCode => Object.hash(
        style,
        styleDegree,
        pitchModifier,
        rateModifier,
        volume,
        emphasisWords != null ? Object.hashAll(emphasisWords!) : null,
        breakBefore,
        breakAfter,
      );

  @override
  String toString() {
    if (!hasContext) return 'DialogueVoiceContext.empty';
    final parts = <String>[];
    if (style != null) parts.add('style: $style');
    if (styleDegree != null) parts.add('styleDegree: $styleDegree');
    if (pitchModifier != null) parts.add('pitch: $pitchModifier');
    if (rateModifier != null) parts.add('rate: $rateModifier');
    if (volume != null) parts.add('volume: $volume');
    if (breakBefore != null) parts.add('breakBefore: ${breakBefore}ms');
    if (breakAfter != null) parts.add('breakAfter: ${breakAfter}ms');
    return 'DialogueVoiceContext(${parts.join(', ')})';
  }

  /// Helper for list equality
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
