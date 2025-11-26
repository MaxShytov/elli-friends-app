# Character Voice Settings - Implementation Plan

**Дата создания:** 2025-11-26
**Обновлено:** 2025-11-26
**Цель:** Реализовать двухуровневую систему голосовых настроек для Azure TTS

> **Текущая задача:** Phase 1-4 выполнены. Следующий шаг: Phase 5 (Тестирование)

---

## Выполненные задачи

### Phase 1: Анализ и выбор оптимальных голосов (COMPLETED)

**Дата выполнения:** 2025-11-26

Проанализированы голоса Azure TTS для всех 7 языков. Выбраны оптимальные голоса:

| Персонаж | EN | RU | DE | FR | IT | AM | MY |
|----------|----|----|----|----|----|----|-----|
| **Orson** (M) | Guy | Dmitry | Conrad | Henri | Diego | Ameha | Thiha |
| **Merv** (F) | Jenny+Girl | Svetlana | Katja | Denise | Isabella | Mekdes | Nilar |

**Параметры для детей 5-7 лет:**
- Orson: rate=0.90, pitch=0%, style=friendly/cheerful
- Merv: rate=0.88, pitch=+5%, style=friendly/cheerful

---

### Phase 2: Обновление characters.json (COMPLETED)

**Дата выполнения:** 2025-11-26

**Изменения в [characters.json](../assets/data/characters.json):**

#### Orson (лев):
- `baseRate`: 0.95 -> 0.90 (медленнее для детей)
- `defaultStyleDegree`: 1.0 -> 1.1 (выразительнее)
- `defaultStyle` для de/fr: "friendly" -> "cheerful" (friendly недоступен)

#### Merv (волшебница):
- `isMale`: true -> false (теперь женский персонаж)
- Голоса: мужские -> женские (Jenny, Svetlana, Katja, Denise, Isabella, Mekdes, Nilar)
- `basePitch`: 5 -> 5 (оставлен)
- `baseRate`: 0.9 -> 0.88 (чуть медленнее)
- `defaultStyle`: null -> "friendly"/"cheerful" (добавлены стили)
- `defaultStyleDegree`: 1.0 -> 1.2 (выразительнее)
- Имена обновлены на женский род во всех языках

**Совместимость:** Уроки `lesson_counting.json` и `lesson_subtraction.json` продолжают работать, т.к. используют `characterId` ("orson", "merv"), который не изменился.

---

### Phase 3: Reset to Default (COMPLETED)

**Дата выполнения:** 2025-11-26

**Созданные файлы:**
- [default_voice_profiles.json](../assets/data/default_voice_profiles.json) - "заводские" настройки для всех персонажей

**Изменения в коде:**

1. **CharacterRepository** - добавлены методы:
   - `resetVoiceProfileToDefault(characterId, languageCode)` - сброс одного языка
   - `resetAllVoiceProfilesToDefault(characterId)` - сброс всех языков персонажа
   - `_loadDefaultProfile()` - загрузка дефолтов из assets
   - `_loadAllDefaultProfiles()` - загрузка всех дефолтов

2. **VoiceSettingsPanel** - добавлена кнопка Reset:
   - Иконка восстановления (restore) слева от Test Voice
   - При нажатии сбрасывает текущий язык к дефолтным значениям
   - Показывает SnackBar с подтверждением

---

### Phase 4: Проверка SeedService (COMPLETED)

**Дата выполнения:** 2025-11-26

**Результат проверки:** SeedService уже полностью реализован и корректно работает.

**Ключевые моменты:**
- `_seedCharacters()` читает из `assets/data/characters.json`
- basePitch конвертируется из int (0, 5) в string ("+0%", "+5%")
- `resetCharacters()` позволяет пересоздать персонажей из assets
- `resetAndReseed()` полностью пересоздаёт БД

**Для применения новых настроек к существующей БД:**
1. Вызвать `SeedService.resetCharacters()` из настроек, ИЛИ
2. Удалить БД и перезапустить приложение

---

## Как проверить результаты

### 1. Тестирование голосов в MascotsDemo

```bash
flutter run -d chrome
```

1. Открыть Settings -> Mascots Demo (или /demo в URL)
2. Выбрать персонажа **Orson**
3. Проверить настройки для EN:
   - Voice: Guy Neural
   - Rate: 0.90
   - Style: friendly
4. Нажать "Test Voice" - должен звучать мужской голос медленно
5. Переключить язык на RU, DE, FR - проверить что голоса разные
6. Выбрать персонажа **Merv**
7. Проверить настройки для EN:
   - Voice: Jenny Neural
   - Role: Girl
   - Rate: 0.88
   - Style: friendly
8. Нажать "Test Voice" - должен звучать женский голос ещё медленнее

### 2. Тестирование в уроках

1. Открыть урок "Counting as a Game of Friends"
2. Прослушать диалоги Orson (мужской голос) и Merv (женский голос)
3. Убедиться, что голоса различаются и хорошо понятны
4. Проверить урок "Subtraction as Hide and Seek" аналогично

### 3. Проверка локализации

Для каждого языка (EN, RU, DE, FR, IT, AM, MY):
1. Сменить язык в настройках
2. Открыть урок
3. Убедиться что голоса соответствуют языку

### 4. Тестирование Reset to Default

1. Открыть Settings -> Mascots Demo
2. Выбрать персонажа **Orson**, язык EN
3. Изменить настройки (например, Rate на 0.50, Pitch на +20%)
4. Нажать **Save** - настройки сохранены
5. Нажать иконку **Reset** (слева от Test Voice)
6. Проверить что настройки вернулись к дефолтным:
   - Rate: 0.90
   - Pitch: 0%
   - Style: friendly
7. Появится синий SnackBar "Reset to default settings for English"

---

## Руководство пользователя

### Как настроить голос персонажа

1. Откройте **Settings** -> **Mascots Demo**
2. Выберите персонажа из списка (Orson, Merv, Elli, Bono, Hippo)
3. Выберите язык для настройки
4. Настройте параметры голоса:
   - **Voice**: выберите голос Azure TTS
   - **Role**: для EN голосов можно выбрать Girl/Boy/YoungAdult/etc.
   - **Style**: emotional style (cheerful, friendly, sad, etc.)
   - **Pitch**: высота голоса (-50% до +50%)
   - **Rate**: скорость речи (0.5 до 2.0)
   - **Style Degree**: интенсивность стиля (0.01 до 2.0)
5. Нажмите **Test Voice** для проверки
6. Нажмите **Save** для сохранения настроек

### Рекомендуемые настройки для детей

| Параметр | Значение | Почему |
|----------|----------|--------|
| Rate | 0.85-0.95 | Медленная речь легче воспринимается |
| Pitch | 0% до +10% | Немного выше для женских персонажей |
| Style | friendly/cheerful | Дружелюбный тон привлекает детей |
| Style Degree | 1.0-1.3 | Умеренная выразительность |

### Различие голосов персонажей

Для лучшего восприятия, голоса персонажей должны различаться:

| Персонаж | Тип | Rate | Pitch | Особенности |
|----------|-----|------|-------|-------------|
| Orson | Взрослый М | 0.90 | 0% | Спокойный учитель |
| Merv | Взрослый Ж | 0.88 | +5% | Медленный, мистический |
| Elli | Взрослый Ж | 1.0 | +8% | Выше и быстрее |
| Bono | Ребёнок | 1.05 | +15% | Высокий детский голос |
| Hippo | Взрослый Ж | 1.0 | +3% | Низкий женский голос |

---

## Архитектура: Два уровня настроек

```
┌─────────────────────────────────────────────────────┐
│              🎭 АКТЁР (Character Profile)           │
│  ┌───────────────────────────────────────────────┐  │
│  │  • languageCode (en, ru, de, fr)              │  │
│  │  • voiceName    (en-US-JennyNeural)           │  │
│  │  • role         (Girl, Boy, etc.)             │  │
│  │  • basePitch    (+8%)                         │  │
│  │  • baseRate     (1.0)                         │  │
│  │  • defaultStyle (friendly)                    │  │
│  └───────────────────────────────────────────────┘  │
│                         │                           │
│                         ▼                           │
│  ┌───────────────────────────────────────────────┐  │
│  │         🎬 ФРАЗА (Dialogue Context)           │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │  • style        (cheerful)              │  │  │
│  │  │  • styleDegree  (1.3)                   │  │  │
│  │  │  • pitchMod     (+5%)  → итого +13%     │  │  │
│  │  │  • rateMod      (0.9)  → итого 0.9      │  │  │
│  │  │  • volume       (medium)                │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### UI Flow: Выбор голоса администратором

```
┌─────────────────────────────────────────────────────┐
│  1. Выбор персонажа (Orson, Elli, Bono...)         │
│                    │                                │
│                    ▼                                │
│  2. Выбор языка [en] [ru] [de] [fr] [it]           │
│                    │                                │
│                    ▼                                │
│  3. Выбор голоса (filtered by language)            │
│     ┌────────────────────────────────────┐         │
│     │ 🔘 Jenny (Female) - styles ✓       │         │
│     │ ○  Guy (Male) - styles ✓           │         │
│     │ ○  Ana (Child) - styles ✓          │         │
│     │ ○  Christopher (Male) - no styles  │         │
│     └────────────────────────────────────┘         │
│                    │                                │
│                    ▼                                │
│  4. Настройка параметров (filtered by voice)       │
│     - Role (if supported)                          │
│     - Default Style (if supported)                 │
│     - Pitch, Rate sliders                          │
│                    │                                │
│                    ▼                                │
│  5. [▶ Test Voice] [💾 Save]                       │
└─────────────────────────────────────────────────────┘
```

---

## Plan

### PHASE 1: Azure TTS Reference Data (Фундамент)

> **Важно:** Это должно быть реализовано ПЕРВЫМ, т.к. всё остальное зависит от этих данных

#### Task 1.1: Создать AzureTtsReference
**Файл:** `lib/core/services/azure_tts_reference.dart` (новый)

**Содержимое:**
```dart
/// Reference data for Azure TTS valid values
/// This is the foundation for all voice selection UI
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
        styles: ['assistant', 'chat', 'customerservice', 'newscast', 'angry',
                 'cheerful', 'sad', 'excited', 'friendly', 'terrified',
                 'shouting', 'unfriendly', 'whispering', 'hopeful'],
        supportsRole: true,
      ),
      AzureVoiceOption(
        name: 'en-US-GuyNeural',
        displayName: 'Guy (Male)',
        gender: 'Male',
        styles: ['newscast', 'angry', 'cheerful', 'sad', 'excited',
                 'friendly', 'terrified', 'shouting', 'unfriendly', 'whispering'],
        supportsRole: true,
      ),
      AzureVoiceOption(
        name: 'en-US-AriaNeural',
        displayName: 'Aria (Female)',
        gender: 'Female',
        styles: ['chat', 'customerservice', 'narration-professional',
                 'newscast-casual', 'newscast-formal', 'cheerful', 'empathetic',
                 'angry', 'sad', 'excited', 'friendly', 'terrified',
                 'shouting', 'unfriendly', 'whispering', 'hopeful'],
        supportsRole: true,
      ),
      AzureVoiceOption(
        name: 'en-US-AnaNeural',
        displayName: 'Ana (Child Female)',
        gender: 'Female',
        styles: ['cheerful', 'sad', 'angry', 'fearful', 'excited',
                 'friendly', 'hopeful'],
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
  };

  // ═══════════════════════════════════════════════════════════════
  // ROLES (for voices that support role-play)
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // PARAMETER LIMITS
  // ═══════════════════════════════════════════════════════════════

  static const double styleDegreeMin = 0.01;
  static const double styleDegreeMax = 2.0;
  static const double styleDegreeDefault = 1.0;

  static const int pitchMin = -50;
  static const int pitchMax = 50;
  static const int pitchDefault = 0;

  static const double rateMin = 0.5;
  static const double rateMax = 2.0;
  static const double rateDefault = 1.0;

  static const List<String> volumeOptions = [
    'silent', 'x-soft', 'soft', 'medium', 'loud', 'x-loud', 'default',
  ];

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get voices for a specific language
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
    };
    return names[code] ?? code;
  }

  /// Format pitch value for display
  static String formatPitch(int pitch) {
    return pitch >= 0 ? '+$pitch%' : '$pitch%';
  }

  /// Parse pitch from string
  static int parsePitch(String pitch) {
    final cleaned = pitch.replaceAll('%', '').replaceAll('+', '');
    return int.tryParse(cleaned) ?? 0;
  }

  /// Format rate value for SSML
  static String formatRate(double rate) {
    final percent = ((rate - 1.0) * 100).round();
    return percent >= 0 ? '+$percent%' : '$percent%';
  }

  /// Get default voice for language and character type
  static String getDefaultVoice(String languageCode, {bool isChild = false, bool isMale = false}) {
    final voices = getVoicesForLanguage(languageCode);

    // Try to find matching voice
    for (final voice in voices) {
      if (isChild && voice.isChildVoice) return voice.name;
      if (!isChild && voice.gender == (isMale ? 'Male' : 'Female') && !voice.isChildVoice) {
        return voice.name;
      }
    }

    // Fallback to first voice
    return voices.first.name;
  }
}

/// Information about an Azure TTS voice
class AzureVoiceOption {
  final String name;           // "en-US-JennyNeural"
  final String displayName;    // "Jenny (Female)"
  final String gender;         // "Female" or "Male"
  final List<String> styles;   // Supported styles
  final bool supportsRole;     // Can use role attribute
  final bool isChildVoice;     // Is this a child voice

  const AzureVoiceOption({
    required this.name,
    required this.displayName,
    required this.gender,
    this.styles = const [],
    this.supportsRole = false,
    this.isChildVoice = false,
  });

  bool get hasStyles => styles.isNotEmpty;
}
```

**Проверка:**
```bash
flutter analyze lib/core/services/azure_tts_reference.dart
```

---

### PHASE 2: Domain Models

#### Task 2.1: Создать CharacterVoiceProfile (с languageCode!)
**Файл:** `lib/features/lessons/domain/entities/character_voice_profile.dart` (новый)

**Содержимое:**
```dart
import '../../../core/services/azure_tts_reference.dart';

/// Voice profile for a character in a specific language
/// Each character has one profile PER language
class CharacterVoiceProfile {
  final String characterId;        // "orson", "elli", etc.
  final String languageCode;       // "en", "ru", "de", etc.
  final String voiceName;          // Azure voice: "en-US-JennyNeural"
  final String? role;              // Azure role: "Girl", "Boy", etc. (only for supported voices)
  final String basePitch;          // Base pitch: "+8%", "-5%", "0%"
  final double baseRate;           // Base rate: 0.5 - 2.0
  final String? defaultStyle;      // Default emotion style (only for supported voices)
  final double defaultStyleDegree; // Default intensity: 0.01 - 2.0

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

  /// Get voice info from reference data
  AzureVoiceOption? get voiceInfo => AzureTtsReference.getVoiceInfo(voiceName);

  /// Check if this voice supports styles
  bool get supportsStyles => voiceInfo?.hasStyles ?? false;

  /// Check if this voice supports roles
  bool get supportsRole => voiceInfo?.supportsRole ?? false;

  /// Get available styles for this voice
  List<String> get availableStyles => voiceInfo?.styles ?? [];

  /// Combine base pitch with modifier
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

  /// Combine base rate with modifier (multiplicative)
  double combineRate(double? modifier) {
    if (modifier == null) return baseRate;
    return (baseRate * modifier).clamp(
      AzureTtsReference.rateMin,
      AzureTtsReference.rateMax,
    );
  }

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

  factory CharacterVoiceProfile.fromJson(Map<String, dynamic> json) {
    return CharacterVoiceProfile(
      characterId: json['characterId'] as String,
      languageCode: json['languageCode'] as String,
      voiceName: json['voiceName'] as String,
      role: json['role'] as String?,
      basePitch: json['basePitch'] as String? ?? '0%',
      baseRate: (json['baseRate'] as num?)?.toDouble() ?? 1.0,
      defaultStyle: json['defaultStyle'] as String?,
      defaultStyleDegree: (json['defaultStyleDegree'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// Create default profile for a character and language
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
}
```

---

#### Task 2.2: Создать DialogueVoiceContext
**Файл:** `lib/features/lessons/domain/entities/dialogue_voice_context.dart` (новый)

**Содержимое:**
```dart
import '../../../core/services/azure_tts_reference.dart';

/// Voice context for a specific dialogue line (Scene level settings)
/// These parameters change based on the emotional context of the scene
class DialogueVoiceContext {
  final String? style;           // Emotion: "cheerful", "excited", "sad"
  final double? styleDegree;     // Intensity: 0.01 - 2.0 (default 1.0)
  final String? pitchModifier;   // Pitch change: "+10%", "-5%"
  final double? rateModifier;    // Rate multiplier: 0.8, 1.2
  final String? volume;          // Volume: "soft", "medium", "loud"
  final List<String>? emphasisWords;
  final int? breakBefore;        // Pause before in ms
  final int? breakAfter;         // Pause after in ms

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

  /// Create from scene tone (legacy support)
  factory DialogueVoiceContext.fromTone(String? tone) {
    if (tone == null) return const DialogueVoiceContext();

    switch (tone.toLowerCase()) {
      case 'excited':
        return const DialogueVoiceContext(
          style: 'excited',
          styleDegree: 1.3,
          pitchModifier: '+5%',
        );
      case 'questioning':
        return const DialogueVoiceContext(
          style: 'friendly',
          pitchModifier: '+10%',
        );
      case 'calm':
        return const DialogueVoiceContext(
          style: 'calm',
          rateModifier: 0.9,
        );
      case 'sad':
        return const DialogueVoiceContext(
          style: 'sad',
          pitchModifier: '-5%',
          rateModifier: 0.85,
        );
      case 'cheerful':
        return const DialogueVoiceContext(
          style: 'cheerful',
          styleDegree: 1.2,
        );
      default:
        return const DialogueVoiceContext(style: 'friendly');
    }
  }

  bool get hasContext =>
      style != null ||
      styleDegree != null ||
      pitchModifier != null ||
      rateModifier != null ||
      volume != null;

  DialogueVoiceContext copyWith({
    String? style,
    double? styleDegree,
    String? pitchModifier,
    double? rateModifier,
    String? volume,
    List<String>? emphasisWords,
    int? breakBefore,
    int? breakAfter,
  }) {
    return DialogueVoiceContext(
      style: style ?? this.style,
      styleDegree: styleDegree ?? this.styleDegree,
      pitchModifier: pitchModifier ?? this.pitchModifier,
      rateModifier: rateModifier ?? this.rateModifier,
      volume: volume ?? this.volume,
      emphasisWords: emphasisWords ?? this.emphasisWords,
      breakBefore: breakBefore ?? this.breakBefore,
      breakAfter: breakAfter ?? this.breakAfter,
    );
  }

  Map<String, dynamic> toJson() => {
    if (style != null) 'style': style,
    if (styleDegree != null) 'styleDegree': styleDegree,
    if (pitchModifier != null) 'pitchModifier': pitchModifier,
    if (rateModifier != null) 'rateModifier': rateModifier,
    if (volume != null) 'volume': volume,
    if (emphasisWords != null) 'emphasisWords': emphasisWords,
    if (breakBefore != null) 'breakBefore': breakBefore,
    if (breakAfter != null) 'breakAfter': breakAfter,
  };

  factory DialogueVoiceContext.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DialogueVoiceContext();
    return DialogueVoiceContext(
      style: json['style'] as String?,
      styleDegree: (json['styleDegree'] as num?)?.toDouble(),
      pitchModifier: json['pitchModifier'] as String?,
      rateModifier: (json['rateModifier'] as num?)?.toDouble(),
      volume: json['volume'] as String?,
      emphasisWords: (json['emphasisWords'] as List?)?.cast<String>(),
      breakBefore: json['breakBefore'] as int?,
      breakAfter: json['breakAfter'] as int?,
    );
  }
}
```

---

### PHASE 3: Database Schema

#### Task 3.1: Создать таблицу Characters
**Файл:** `lib/core/database/app_database.dart`

**Изменения:**
```dart
/// Characters table - stores character metadata and voice profiles
class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get characterId => text().unique()(); // "orson", "elli"
  TextColumn get nameJson => text()(); // {"en": "Orson", "ru": "Орсон"}
  TextColumn get emoji => text()(); // "🦁"
  TextColumn get descriptionJson => text().nullable()();

  // Voice profiles per language - Map<languageCode, CharacterVoiceProfile>
  // {"en": {"voiceName": "en-US-JennyNeural", ...}, "ru": {...}}
  TextColumn get voiceProfilesJson => text()();

  // Visual settings
  TextColumn get color => text().withDefault(const Constant('#FF9800'))();

  // Character type hints for default voice selection
  BoolColumn get isChild => boolean().withDefault(const Constant(false))();
  BoolColumn get isMale => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Порядок выполнения:**
1. Добавить класс Characters в `app_database.dart`
2. Добавить в `@DriftDatabase(tables: [..., Characters])`
3. Увеличить `schemaVersion` до 2
4. Добавить миграцию
5. Запустить `flutter pub run build_runner build --delete-conflicting-outputs`

---

#### Task 3.2: Добавить поле voiceContextJson в Scenes
**Файл:** `lib/core/database/app_database.dart`

**Изменения в классе Scenes:**
```dart
class Scenes extends Table {
  // ... existing fields ...

  // Voice context for this scene's dialogue (DialogueVoiceContext as JSON)
  TextColumn get voiceContextJson => text().nullable()();
}
```

---

#### Task 3.3: Создать CharacterRepository
**Файл:** `lib/core/database/character_repository.dart` (новый)

```dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../features/lessons/domain/entities/character_voice_profile.dart';
import '../services/azure_tts_reference.dart';
import 'app_database.dart';

class CharacterRepository {
  final AppDatabase _db;

  CharacterRepository(this._db);

  /// Get all characters
  Future<List<Character>> getAllCharacters() {
    return _db.select(_db.characters).get();
  }

  /// Get character by ID
  Future<Character?> getCharacter(String characterId) {
    return (_db.select(_db.characters)
          ..where((c) => c.characterId.equals(characterId)))
        .getSingleOrNull();
  }

  /// Get voice profile for character and language
  Future<CharacterVoiceProfile?> getVoiceProfile(
    String characterId,
    String languageCode,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return null;

    final profiles = jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    final profileJson = profiles[languageCode] as Map<String, dynamic>?;

    if (profileJson == null) {
      // Return default profile if language not configured
      return CharacterVoiceProfile.defaultFor(
        characterId: characterId,
        languageCode: languageCode,
        isChild: character.isChild,
        isMale: character.isMale,
      );
    }

    return CharacterVoiceProfile.fromJson({
      'characterId': characterId,
      'languageCode': languageCode,
      ...profileJson,
    });
  }

  /// Get all voice profiles for a character (all languages)
  Future<Map<String, CharacterVoiceProfile>> getAllVoiceProfiles(
    String characterId,
  ) async {
    final character = await getCharacter(characterId);
    if (character == null) return {};

    final profiles = jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;
    final result = <String, CharacterVoiceProfile>{};

    for (final lang in AzureTtsReference.availableLanguages) {
      final profileJson = profiles[lang] as Map<String, dynamic>?;
      if (profileJson != null) {
        result[lang] = CharacterVoiceProfile.fromJson({
          'characterId': characterId,
          'languageCode': lang,
          ...profileJson,
        });
      }
    }

    return result;
  }

  /// Update voice profile for a specific language
  Future<void> updateVoiceProfile(CharacterVoiceProfile profile) async {
    final character = await getCharacter(profile.characterId);
    if (character == null) return;

    final profiles = jsonDecode(character.voiceProfilesJson) as Map<String, dynamic>;

    profiles[profile.languageCode] = {
      'voiceName': profile.voiceName,
      'role': profile.role,
      'basePitch': profile.basePitch,
      'baseRate': profile.baseRate,
      'defaultStyle': profile.defaultStyle,
      'defaultStyleDegree': profile.defaultStyleDegree,
    };

    await (_db.update(_db.characters)
          ..where((c) => c.characterId.equals(profile.characterId)))
        .write(CharactersCompanion(
      voiceProfilesJson: Value(jsonEncode(profiles)),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Insert or update character
  Future<void> upsertCharacter(CharactersCompanion character) {
    return _db.into(_db.characters).insertOnConflictUpdate(character);
  }
}
```

---

### PHASE 4: Seed Data

#### Task 4.1: Добавить seed данные для персонажей
**Файл:** `lib/core/database/seed_service.dart`

```dart
Future<void> _seedCharacters() async {
  final characters = [
    CharactersCompanion.insert(
      characterId: 'orson',
      nameJson: '{"en": "Orson the Lion", "ru": "Орсон Лев"}',
      emoji: '🦁',
      isMale: const Value(true),
      voiceProfilesJson: jsonEncode({
        'en': {
          'voiceName': 'en-US-GuyNeural',
          'role': 'OlderAdultMale',
          'basePitch': '-5%',
          'baseRate': 0.95,
          'defaultStyle': 'friendly',
          'defaultStyleDegree': 1.0,
        },
        'ru': {
          'voiceName': 'ru-RU-DmitryNeural',
          'basePitch': '-5%',
          'baseRate': 0.95,
        },
        'de': {
          'voiceName': 'de-DE-ConradNeural',
          'basePitch': '-5%',
          'baseRate': 0.95,
          'defaultStyle': 'cheerful',
        },
      }),
      color: const Value('#FF9800'),
    ),
    CharactersCompanion.insert(
      characterId: 'elli',
      nameJson: '{"en": "Elli the Elephant", "ru": "Элли Слонёнок"}',
      emoji: '🐘',
      voiceProfilesJson: jsonEncode({
        'en': {
          'voiceName': 'en-US-JennyNeural',
          'role': 'Girl',
          'basePitch': '+8%',
          'baseRate': 1.0,
          'defaultStyle': 'cheerful',
          'defaultStyleDegree': 1.1,
        },
        'ru': {
          'voiceName': 'ru-RU-SvetlanaNeural',
          'basePitch': '+5%',
          'baseRate': 1.0,
        },
      }),
      color: const Value('#E91E63'),
    ),
    CharactersCompanion.insert(
      characterId: 'bono',
      nameJson: '{"en": "Bono the Baby Elephant", "ru": "Боно Слонёнок"}',
      emoji: '🐘',
      isChild: const Value(true),
      voiceProfilesJson: jsonEncode({
        'en': {
          'voiceName': 'en-US-AnaNeural',
          'basePitch': '+15%',
          'baseRate': 1.05,
          'defaultStyle': 'cheerful',
          'defaultStyleDegree': 1.3,
        },
        'ru': {
          'voiceName': 'ru-RU-DariyaNeural',
          'basePitch': '+10%',
          'baseRate': 1.0,
        },
        'de': {
          'voiceName': 'de-DE-GiselaNeural',
          'basePitch': '+10%',
          'baseRate': 1.0,
        },
        'fr': {
          'voiceName': 'fr-FR-EloiseNeural',
          'basePitch': '+10%',
          'baseRate': 1.0,
        },
      }),
      color: const Value('#2196F3'),
    ),
    CharactersCompanion.insert(
      characterId: 'merv',
      nameJson: '{"en": "Merv the Wizard", "ru": "Мерв Волшебник"}',
      emoji: '🧙',
      isMale: const Value(true),
      voiceProfilesJson: jsonEncode({
        'en': {
          'voiceName': 'en-US-ChristopherNeural',
          'basePitch': '-10%',
          'baseRate': 0.9,
        },
        'ru': {
          'voiceName': 'ru-RU-DmitryNeural',
          'basePitch': '-10%',
          'baseRate': 0.9,
        },
      }),
      color: const Value('#9C27B0'),
    ),
    CharactersCompanion.insert(
      characterId: 'hippo',
      nameJson: '{"en": "Hippo", "ru": "Бегемот"}',
      emoji: '🦛',
      voiceProfilesJson: jsonEncode({
        'en': {
          'voiceName': 'en-US-AriaNeural',
          'role': 'YoungAdultFemale',
          'basePitch': '-3%',
          'baseRate': 0.92,
          'defaultStyle': 'friendly',
        },
        'ru': {
          'voiceName': 'ru-RU-SvetlanaNeural',
          'basePitch': '-3%',
          'baseRate': 0.92,
        },
      }),
      color: const Value('#009688'),
    ),
  ];

  for (final character in characters) {
    await _db.into(_db.characters).insertOnConflictUpdate(character);
  }

  debugPrint('SeedService: Seeded ${characters.length} characters');
}
```

---

### PHASE 5: Update AzureTtsService

#### Task 5.1: Рефакторинг для использования CharacterVoiceProfile
**Файл:** `lib/core/services/azure_tts_service.dart`

```dart
/// Generate audio with two-level voice settings
Future<Uint8List> generateAudio({
  required String text,
  required CharacterVoiceProfile actorProfile,
  DialogueVoiceContext? dialogueContext,
}) async {
  if (text.trim().isEmpty) {
    throw AzureTtsException('Text cannot be empty');
  }

  // Get locale from voice name (e.g., "en-US-JennyNeural" -> "en-US")
  final locale = actorProfile.voiceName.substring(0, 5);

  // Combine actor base settings with dialogue context
  final style = dialogueContext?.style ?? actorProfile.defaultStyle;
  final styleDegree = dialogueContext?.styleDegree ?? actorProfile.defaultStyleDegree;
  final pitch = actorProfile.combinePitch(dialogueContext?.pitchModifier);
  final rate = actorProfile.combineRate(dialogueContext?.rateModifier);
  final volume = dialogueContext?.volume;

  // Only use style/role if voice supports them
  final useStyle = actorProfile.supportsStyles && style != null;
  final useRole = actorProfile.supportsRole && actorProfile.role != null;

  final ssml = _buildSsml(
    text: text,
    voiceName: actorProfile.voiceName,
    locale: locale,
    role: useRole ? actorProfile.role : null,
    style: useStyle ? style : null,
    styleDegree: useStyle ? styleDegree : null,
    pitch: pitch,
    rate: rate,
    volume: volume,
    breakBefore: dialogueContext?.breakBefore,
    breakAfter: dialogueContext?.breakAfter,
  );

  debugPrint('Azure TTS: voice=${actorProfile.voiceName}, '
      'style=${useStyle ? style : "N/A"}, pitch=$pitch, rate=$rate');

  // ... HTTP request (unchanged)
}
```

---

### PHASE 6: Character Voice Settings UI

> **Решение:** Вместо создания отдельных страниц, расширяем существующую `MascotsDemo` страницу,
> добавляя функционал настройки голоса. Это дает единый интерфейс для просмотра анимаций
> персонажа и настройки его голоса.

#### Task 6.1: Расширить MascotsDemo для настройки голоса
**Файл:** `lib/features/demo/mascots_demo.dart` (расширение существующего)

**Новый UI Layout:**
```
┌─────────────────────────────────────────────────────────────┐
│  🎭 Character Voice Settings                                 │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────┐  │
│  │                                                       │  │
│  │         [Rive Animation Character Preview]            │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  Character: [Orson ▼]  [Merv]  [Elli]  [Bono]  [Hippo]     │
│                                                             │
│  Emotions: [😊 Happy] [😢 Sad] [😠 Angry] [🤩 Excited] ... │
│                                                             │
│  ═══════════════════ Voice Settings ════════════════════   │
│                                                             │
│  Language:  [🇺🇸 English ▼]                                 │
│                                                             │
│  Voice:     [Jenny Neural (Female) ▼]                      │
│             ℹ️ 14 styles available                          │
│                                                             │
│  Role:      [Girl ▼]  (показывается если голос поддерживает)│
│                                                             │
│  Style:     [Friendly ▼]  (показывается если голос поддерж.)│
│             ⚠️ Russian voices don't support styles          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Pitch:     ──────●────── 0%                         │   │
│  │ Rate:      ────●──────── -10% (0.9x)                │   │
│  │ StyleDeg:  ──────────●── 1.5 (если есть стили)      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Test phrase: "Hello! I'm Orson the lion."                 │
│                                                             │
│  [▶ Test Voice]                      [💾 Save for Language] │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Функционал:**
1. **Верхняя часть (существующая):**
   - Rive анимация персонажа
   - Селектор персонажа (Orson, Merv, Elli, Bono, Hippo)
   - Кнопки эмоций/анимаций

2. **Нижняя часть (новая - Voice Settings):**
   - Селектор языка (7 языков)
   - Dropdown голоса (фильтруется по языку из `AzureTtsReference`)
   - Dropdown роли (если голос поддерживает - `AzureVoiceOption.roles`)
   - Dropdown стиля (если голос поддерживает - `AzureVoiceOption.styles`)
   - Sliders для pitch/rate/styleDegree
   - Кнопка тестирования голоса
   - Кнопка сохранения профиля для текущего языка

**Примечания:**
- При смене языка загружается сохраненный профиль для этого персонажа+языка
- Если профиля нет - используются дефолтные значения из seed data
- При смене голоса - обновляются доступные стили/роли
- Тест фраза генерируется для текущего языка

---

#### Task 6.2: Создать VoiceSettingsPanel widget
**Файл:** `lib/features/demo/widgets/voice_settings_panel.dart` (новый)

```dart
class VoiceSettingsPanel extends StatefulWidget {
  final String characterId;
  final CharacterVoiceProfile? currentProfile;
  final ValueChanged<CharacterVoiceProfile> onProfileChanged;
  final VoidCallback onTestVoice;
  final VoidCallback onSaveProfile;

  const VoiceSettingsPanel({
    super.key,
    required this.characterId,
    this.currentProfile,
    required this.onProfileChanged,
    required this.onTestVoice,
    required this.onSaveProfile,
  });

  @override
  State<VoiceSettingsPanel> createState() => _VoiceSettingsPanelState();
}

class _VoiceSettingsPanelState extends State<VoiceSettingsPanel> {
  String _selectedLanguage = 'en';
  late CharacterVoiceProfile _profile;

  @override
  Widget build(BuildContext context) {
    final voiceOptions = AzureTtsReference.getVoicesForLanguage(_selectedLanguage);
    final selectedVoice = voiceOptions.firstWhere(
      (v) => v.name == _profile.voiceName,
      orElse: () => voiceOptions.first,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('🔊 Voice Settings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            // Language selector
            _LanguageDropdown(
              value: _selectedLanguage,
              onChanged: _onLanguageChanged,
            ),

            // Voice selector
            _VoiceDropdown(
              voices: voiceOptions,
              selectedVoice: selectedVoice,
              onChanged: _onVoiceChanged,
            ),

            // Role selector (conditional)
            if (selectedVoice.roles.isNotEmpty)
              _RoleDropdown(
                roles: selectedVoice.roles,
                selectedRole: _profile.role,
                onChanged: _onRoleChanged,
              ),

            // Style selector (conditional)
            if (selectedVoice.styles.isNotEmpty)
              _StyleDropdown(
                styles: selectedVoice.styles,
                selectedStyle: _profile.defaultStyle,
                onChanged: _onStyleChanged,
              )
            else
              _NoStylesWarning(languageCode: _selectedLanguage),

            // Prosody sliders
            _ProsodySliders(
              pitch: _profile.basePitch,
              rate: _profile.baseRate,
              styleDegree: selectedVoice.styles.isNotEmpty ? 1.0 : null,
              onPitchChanged: (v) => _updateProfile(basePitch: v),
              onRateChanged: (v) => _updateProfile(baseRate: v),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onTestVoice,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Voice'),
                ),
                FilledButton.icon(
                  onPressed: widget.onSaveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

#### Task 6.3: Обновить SceneEditorDialog для DialogueVoiceContext
**Файл:** `lib/features/editor/presentation/widgets/scene_editor_dialog.dart`

**Добавить в Settings Tab:**
- SceneVoiceContextPicker widget
- Показывает только стили, доступные для голоса персонажа выбранного в сцене
- Использует `AzureTtsReference.getVoicesForLanguage()` для получения доступных стилей

```dart
class SceneVoiceContextPicker extends StatelessWidget {
  final String? characterId;
  final String languageCode;
  final DialogueVoiceContext? voiceContext;
  final ValueChanged<DialogueVoiceContext> onChanged;

  @override
  Widget build(BuildContext context) {
    // Получаем голос персонажа для языка
    final profile = characterRepository.getVoiceProfile(characterId, languageCode);
    final voiceOption = AzureTtsReference.getVoiceByName(profile.voiceName);

    return Column(
      children: [
        // Style override (only if voice supports styles)
        if (voiceOption?.styles.isNotEmpty ?? false)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Scene Style Override'),
            value: voiceContext?.style,
            items: [
              DropdownMenuItem(value: null, child: Text('Use default')),
              ...voiceOption!.styles.map((s) =>
                DropdownMenuItem(value: s, child: Text(s)),
              ),
            ],
            onChanged: (style) => onChanged(voiceContext?.copyWith(style: style)),
          ),

        // Style degree slider
        if (voiceOption?.styles.isNotEmpty ?? false)
          Slider(
            value: voiceContext?.styleDegree ?? 1.0,
            min: 0.0,
            max: 2.0,
            label: 'Style Intensity: ${voiceContext?.styleDegree ?? 1.0}',
            onChanged: (v) => onChanged(voiceContext?.copyWith(styleDegree: v)),
          ),

        // Pitch/Rate modifiers
        _ProsodyModifierSliders(
          pitchModifier: voiceContext?.pitchModifier ?? 0,
          rateModifier: voiceContext?.rateModifier ?? 0,
          onChanged: (pitch, rate) => onChanged(
            voiceContext?.copyWith(pitchModifier: pitch, rateModifier: rate),
          ),
        ),
      ],
    );
  }
}
```

---

### PHASE 7: Integration ✅ COMPLETED (2025-11-26)

#### Task 7.1: Обновить AudioManager ✅
- Добавлен `setCharacterRepository()` для загрузки voice profiles
- Добавлен `setAzureTtsService()` для Azure TTS
- Добавлен `loadVoiceProfiles()` для загрузки профилей по текущему языку
- Добавлен `speakDialogueWithProfile()` для полной поддержки voice profiles
- Обновлён `speakDialogue()` с поддержкой `tone` параметра
- Добавлен `_speakWithAzureTts()` для генерации через Azure
- При смене языка (`changeLanguage()`) автоматически перезагружаются профили

#### Task 7.2: Обновить LessonPage ✅
- Добавлена загрузка CharacterRepository в `_initializeAudio()`
- Вызов `loadVoiceProfiles()` после инициализации AudioManager
- Передача `tone` из сцены в `speakDialogue()` для DialogueVoiceContext

**Важно:** Обратная совместимость сохранена - если Azure TTS недоступен или CharacterRepository не настроен, используется системный TTS (fallback).

---

### PHASE 8: Hybrid Audio System

(Содержимое остается как было - CLI tool, pre-bundled assets, HybridAudioService)

---

### PHASE 9: Tests

#### Unit Tests:
- `azure_tts_reference_test.dart`
- `character_voice_profile_test.dart`
- `dialogue_voice_context_test.dart`
- `character_repository_test.dart`

#### Widget Tests:
- `mascots_demo_voice_test.dart` (расширенная MascotsDemo с voice settings)
- `voice_settings_panel_test.dart`
- `scene_voice_context_picker_test.dart`

---

## Чеклист готовности

### Phase 1: Azure TTS Reference ⭐ FIRST ✅ COMPLETED (2025-11-26)
- [x] `AzureTtsReference` класс создан
- [x] Голоса по языкам настроены (7 языков: en, ru, de, fr, it, am, my)
- [x] Стили для каждого голоса указаны
- [x] Helper методы работают

### Phase 2: Domain Models ✅ COMPLETED (2025-11-26)
- [x] `CharacterVoiceProfile` с `languageCode` создан
- [x] `DialogueVoiceContext` создан
- [x] Интеграция с `AzureTtsReference`

### Phase 3: Database ✅ COMPLETED (2025-11-26)
- [x] Таблица `Characters` создана (app_database.dart, schema v2)
- [x] `voiceContextJson` добавлено в `Scenes`
- [x] `backgroundKey` добавлено в `Scenes`
- [x] `CharacterRepository` создан

### Phase 4: Seed Data ✅ COMPLETED (2025-11-26)
- [x] 5 персонажей с voice profiles (orson, merv, elli, bono, hippo)
- [x] Профили для всех 7 языков (en, ru, de, fr, it, am, my)
- [x] JSON файл: `assets/data/characters.json`
- [x] SeedService обновлён для загрузки из JSON
- [x] Reset функционал включает сброс персонажей

### Phase 5: AzureTtsService ✅ COMPLETED (2025-11-26)
- [x] Принимает `CharacterVoiceProfile`
- [x] Принимает `DialogueVoiceContext` (опционально)
- [x] Проверяет поддержку styles/roles
- [x] SSML генерируется корректно (с role, styleDegree, breaks, volume)
- [x] Обратная совместимость сохранена (legacy `generateAudio` работает)

### Phase 6: UI (Расширение MascotsDemo) ✅ COMPLETED (2025-11-26)
- [x] `VoiceSettingsPanel` widget создан
- [x] Language selector работает (7 языков с флагами)
- [x] Voice dropdown фильтруется по языку
- [x] Style/Role показываются условно (только если голос поддерживает)
- [x] Prosody sliders (pitch/rate/styleDegree) работают
- [x] Test Voice интегрирован с Azure TTS
- [x] Save сохраняет профиль в CharacterRepository
- [ ] `SceneVoiceContextPicker` для SceneEditorDialog (Phase 7)

### Phase 7: Integration ✅ COMPLETED (2025-11-26)
- [x] AudioManager интегрирован с CharacterRepository
- [x] AudioManager интегрирован с AzureTtsService (generateAudioWithProfile)
- [x] LessonPage загружает voice profiles при инициализации
- [x] tone из сцен передаётся в DialogueVoiceContext
- [x] Fallback на системный TTS работает
- [x] Обратная совместимость с существующими уроками сохранена

### Phase 8-9: Hybrid Audio System & Tests
- [ ] CLI tool для предварительной генерации аудио
- [ ] Pre-bundled assets
- [ ] Тесты проходят

---

## Пример итогового SSML

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="en-US">
  <voice name="en-US-JennyNeural">
    <mstts:express-as style="cheerful" styledegree="1.3" role="Girl">
      <prosody rate="+5%" pitch="+13%">
        Look! One, two, three apples!
      </prosody>
    </mstts:express-as>
  </voice>
</speak>
```

Для русского голоса (без стилей):
```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xml:lang="ru-RU">
  <voice name="ru-RU-SvetlanaNeural">
    <prosody rate="-5%" pitch="+5%">
      Смотри! Один, два, три яблока!
    </prosody>
  </voice>
</speak>
```

---

## 📋 Выполненные фазы

### ✅ Phase 1: Azure TTS Reference Data — COMPLETED (2025-11-26)

#### Что было сделано:

**Создан файл:** `lib/core/services/azure_tts_reference.dart`

**Содержимое:**

1. **Класс `AzureTtsReference`** — статический класс со справочными данными Azure TTS:
   - Голоса для 7 языков: English, Русский, Deutsch, Français, Italiano, Amharic, Burmese
   - Стили для каждого голоса (cheerful, sad, excited, friendly и др.)
   - Роли для голосов с поддержкой role-play (Girl, Boy, YoungAdultMale и др.)
   - Лимиты параметров (pitch: -50% до +50%, rate: 0.5 до 2.0, styleDegree: 0.01 до 2.0)
   - Опции громкости (silent, x-soft, soft, medium, loud, x-loud, default)

2. **Класс `AzureVoiceOption`** — модель данных голоса:
   - `name` — полное имя голоса (e.g., "en-US-JennyNeural")
   - `displayName` — имя для отображения в UI
   - `gender` — пол голоса (Male/Female)
   - `styles` — поддерживаемые эмоциональные стили
   - `supportsRole` — поддержка role-play
   - `isChildVoice` — детский голос

3. **Helper методы:**
   - `getVoicesForLanguage(languageCode)` — получить голоса для языка
   - `getVoiceInfo(voiceName)` — получить информацию о голосе
   - `getStylesForVoice(voiceName)` — получить стили голоса
   - `voiceSupportsRole(voiceName)` — проверить поддержку ролей
   - `voiceSupportsStyles(voiceName)` — проверить поддержку стилей
   - `formatPitch(int)` / `parsePitch(String)` — форматирование pitch
   - `formatRate(double)` / `parseRate(String)` — форматирование rate
   - `getDefaultVoice(languageCode, isChild, isMale)` — голос по умолчанию
   - `getLocaleFromVoice(voiceName)` — извлечь locale из имени голоса
   - `isStyleValidForVoice(voiceName, style)` — валидация стиля

---

## 📖 Инструкция для разработчиков

### Как использовать AzureTtsReference

```dart
import 'package:elli_friends_app/core/services/azure_tts_reference.dart';

// 1. Получить все доступные языки
final languages = AzureTtsReference.availableLanguages;
// ['en', 'ru', 'de', 'fr', 'it', 'am', 'my']

// 2. Получить голоса для языка
final englishVoices = AzureTtsReference.getVoicesForLanguage('en');
// [AzureVoiceOption(en-US-JennyNeural), AzureVoiceOption(en-US-GuyNeural), ...]

// 3. Получить информацию о конкретном голосе
final jenny = AzureTtsReference.getVoiceInfo('en-US-JennyNeural');
print(jenny?.displayName);  // "Jenny (Female)"
print(jenny?.hasStyles);    // true
print(jenny?.styles);       // ['assistant', 'chat', 'cheerful', ...]

// 4. Проверить поддержку функций голоса
final supportsStyles = AzureTtsReference.voiceSupportsStyles('en-US-JennyNeural');  // true
final supportsRole = AzureTtsReference.voiceSupportsRole('en-US-JennyNeural');      // true

// 5. Получить голос по умолчанию для персонажа
final childVoice = AzureTtsReference.getDefaultVoice('en', isChild: true);  // 'en-US-AnaNeural'
final maleVoice = AzureTtsReference.getDefaultVoice('ru', isMale: true);    // 'ru-RU-DmitryNeural'

// 6. Форматирование параметров для SSML
final pitchStr = AzureTtsReference.formatPitch(10);   // '+10%'
final rateStr = AzureTtsReference.formatRate(0.9);    // '-10%'

// 7. Получить отображаемое название языка
final langName = AzureTtsReference.getLanguageDisplayName('ru');  // 'Русский'
final langFlag = AzureTtsReference.getLanguageFlag('ru');         // '🇷🇺'

// 8. Валидация стиля для голоса
final isValid = AzureTtsReference.isStyleValidForVoice(
  'en-US-JennyNeural',
  'cheerful'
);  // true
```

### Поддерживаемые голоса по языкам

| Язык | Голоса | Со стилями |
|------|--------|------------|
| 🇺🇸 English | Jenny, Guy, Aria, Ana, Christopher, Eric, Michelle, Roger | Jenny ✓, Guy ✓, Aria ✓, Ana ✓ |
| 🇷🇺 Русский | Светлана, Дмитрий, Дария | - |
| 🇩🇪 Deutsch | Katja, Conrad, Gisela, Killian, Amala | Katja ✓, Conrad ✓ |
| 🇫🇷 Français | Denise, Henri, Eloise, Alain, Brigitte | Denise ✓, Henri ✓ |
| 🇮🇹 Italiano | Elsa, Isabella, Diego, Giuseppe, Pierina | Isabella ✓ |
| 🇪🇹 Amharic | Mekdes, Ameha | - |
| 🇲🇲 Burmese | Nilar, Thiha | - |

### Голоса с поддержкой Role-play

Только английские голоса поддерживают role attribute:
- `en-US-JennyNeural`
- `en-US-GuyNeural`
- `en-US-AriaNeural`

Доступные роли: Girl, Boy, YoungAdultFemale, YoungAdultMale, OlderAdultFemale, OlderAdultMale, SeniorFemale, SeniorMale

---

### ✅ Phase 2: Domain Models — COMPLETED (2025-11-26)

#### Что было сделано:

**Созданы файлы:**
- `lib/features/lessons/domain/entities/character_voice_profile.dart`
- `lib/features/lessons/domain/entities/dialogue_voice_context.dart`

#### 1. CharacterVoiceProfile — Голосовой профиль персонажа

Модель уровня "Актёр" — базовые настройки голоса для персонажа в конкретном языке.

**Поля:**
- `characterId` — идентификатор персонажа ("orson", "elli", "bono")
- `languageCode` — код языка ("en", "ru", "de")
- `voiceName` — имя голоса Azure ("en-US-JennyNeural")
- `role` — роль для role-play голосов ("Girl", "Boy", etc.)
- `basePitch` — базовая высота голоса ("+8%", "-5%")
- `baseRate` — базовая скорость речи (0.5 - 2.0)
- `defaultStyle` — стиль по умолчанию ("cheerful", "friendly")
- `defaultStyleDegree` — интенсивность стиля (0.01 - 2.0)

**Методы:**
- `combinePitch(modifier)` — комбинирует базовый pitch с модификатором
- `combineRate(modifier)` — комбинирует базовую скорость с множителем
- `getEffectiveStyle(contextStyle)` — получить эффективный стиль
- `copyWith(...)` — создать копию с изменениями
- `toJson()` / `fromJson()` — сериализация
- `defaultFor(characterId, languageCode, isChild, isMale)` — профиль по умолчанию

#### 2. DialogueVoiceContext — Контекст голоса для фразы

Модель уровня "Фраза" — эмоциональные настройки для конкретной реплики.

**Поля:**
- `style` — эмоциональный стиль ("excited", "sad", "angry")
- `styleDegree` — интенсивность стиля (0.01 - 2.0)
- `pitchModifier` — модификатор pitch ("+10%", "-5%")
- `rateModifier` — модификатор скорости (0.8, 1.2)
- `volume` — громкость ("soft", "loud", "x-loud")
- `emphasisWords` — слова для выделения
- `breakBefore` / `breakAfter` — паузы в мс

**Factory-конструкторы для эмоций:**
- `DialogueVoiceContext.excited()` — возбуждённая речь
- `DialogueVoiceContext.cheerful()` — весёлая речь
- `DialogueVoiceContext.sad()` — грустная речь
- `DialogueVoiceContext.angry()` — злая речь
- `DialogueVoiceContext.calm()` — спокойная речь
- `DialogueVoiceContext.whisper()` — шёпот
- `DialogueVoiceContext.shout()` — крик
- `DialogueVoiceContext.questioning()` — вопросительный тон
- `DialogueVoiceContext.fromTone(tone)` — из строки тона (legacy)

---

### Как использовать Domain Models

```dart
import 'package:elli_friends_app/features/lessons/domain/entities/character_voice_profile.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/dialogue_voice_context.dart';

// 1. Создать профиль персонажа
final elliProfile = CharacterVoiceProfile(
  characterId: 'elli',
  languageCode: 'en',
  voiceName: 'en-US-JennyNeural',
  role: 'Girl',
  basePitch: '+8%',
  baseRate: 1.0,
  defaultStyle: 'cheerful',
  defaultStyleDegree: 1.1,
);

// 2. Проверить возможности голоса
print(elliProfile.supportsStyles);    // true
print(elliProfile.supportsRole);      // true
print(elliProfile.availableStyles);   // ['assistant', 'chat', 'cheerful', ...]

// 3. Создать профиль по умолчанию
final bonoProfile = CharacterVoiceProfile.defaultFor(
  characterId: 'bono',
  languageCode: 'en',
  isChild: true,
);
print(bonoProfile.voiceName);  // 'en-US-AnaNeural'

// 4. Создать контекст для эмоциональной фразы
final excitedContext = DialogueVoiceContext.excited(intensity: 1.5);
final sadContext = DialogueVoiceContext.sad();

// 5. Создать контекст из тона (legacy support)
final context = DialogueVoiceContext.fromTone('cheerful');

// 6. Комбинировать профиль и контекст
final finalPitch = elliProfile.combinePitch(excitedContext.pitchModifier);
print(finalPitch);  // '+13%' (base +8% + modifier +5%)

final finalRate = elliProfile.combineRate(excitedContext.rateModifier);
print(finalRate);   // 1.1 (base 1.0 * modifier 1.1)

// 7. Получить эффективный стиль
final style = elliProfile.getEffectiveStyle(excitedContext.style);
print(style);  // 'excited'

// 8. Сериализация
final json = elliProfile.toJson();
final restored = CharacterVoiceProfile.fromJson(json);
```

### Двухуровневая архитектура голоса

```
┌─────────────────────────────────────────────────────┐
│              🎭 CharacterVoiceProfile               │
│  (Уровень персонажа - базовые настройки)            │
│  ┌───────────────────────────────────────────────┐  │
│  │  • voiceName    (en-US-JennyNeural)           │  │
│  │  • role         (Girl)                        │  │
│  │  • basePitch    (+8%)                         │  │
│  │  • baseRate     (1.0)                         │  │
│  │  • defaultStyle (cheerful)                    │  │
│  └───────────────────────────────────────────────┘  │
│                         ↓                           │
│  ┌───────────────────────────────────────────────┐  │
│  │         🎬 DialogueVoiceContext               │  │
│  │  (Уровень фразы - эмоциональные модификаторы) │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │  • style        (excited)               │  │  │
│  │  │  • styleDegree  (1.3)                   │  │  │
│  │  │  • pitchMod     (+5%)  → итого +13%     │  │  │
│  │  │  • rateMod      (1.1)  → итого 1.1      │  │  │
│  │  │  • volume       (loud)                  │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

### ✅ Phase 3: Database Schema — COMPLETED (2025-11-26)

#### Что было сделано:

**1. Таблица `Characters` создана**

**Файл:** `lib/core/database/app_database.dart`

Новая таблица для хранения персонажей и их голосовых профилей:

```dart
class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get characterId => text().unique()();     // "orson", "elli"
  TextColumn get nameJson => text()();                  // {"en": "Orson", "ru": "Орсон"}
  TextColumn get emoji => text()();                     // "🦁"
  TextColumn get descriptionJson => text().nullable()();
  TextColumn get voiceProfilesJson => text()();         // {"en": {...}, "ru": {...}}
  TextColumn get color => text().withDefault(const Constant('#FF9800'))();
  BoolColumn get isChild => boolean().withDefault(const Constant(false))();
  BoolColumn get isMale => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**2. Поля добавлены в таблицу `Scenes`**

```dart
// Voice context for this scene's dialogue (DialogueVoiceContext as JSON)
TextColumn get voiceContextJson => text().nullable()();

// Background image or gradient key for scene
TextColumn get backgroundKey => text().nullable()();
```

**3. Миграция базы данных**

- Schema version обновлена: `1 → 2`
- Миграция автоматически создаёт таблицу `Characters` при обновлении
- Миграция добавляет новые колонки в `Scenes`

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(characters);
        await m.addColumn(scenes, scenes.voiceContextJson);
        await m.addColumn(scenes, scenes.backgroundKey);
      }
    },
  );
}
```

**4. CharacterRepository создан**

**Файл:** `lib/core/database/character_repository.dart`

```dart
class CharacterRepository {
  final AppDatabase _db;

  // Character operations
  Future<List<Character>> getAllCharacters();
  Future<Character?> getCharacter(String characterId);
  Stream<List<Character>> watchAllCharacters();

  // Voice profile operations
  Future<CharacterVoiceProfile?> getVoiceProfile(String characterId, String languageCode);
  Future<Map<String, CharacterVoiceProfile>> getAllVoiceProfiles(String characterId);
  Future<void> updateVoiceProfile(CharacterVoiceProfile profile);

  // Helper methods
  Future<String?> getCharacterName(String characterId, String languageCode);
  Future<List<String>> getConfiguredLanguages(String characterId);
}
```

**5. SeedService обновлён**

**Файл:** `lib/core/database/seed_service.dart`

- Загружает персонажей из `assets/data/characters.json`
- Конвертирует pitch из int в string формат (e.g., `5` → `"+5%"`)
- Методы: `seedFromAssets()`, `resetCharacters()`, `resetAndReseed()`

---

### ✅ Phase 4: Seed Data — COMPLETED (2025-11-26)

#### Что было сделано:

**Файл:** `assets/data/characters.json`

5 персонажей с голосовыми профилями для 7 языков:

| Персонаж | Emoji | Тип | Цвет | Голос EN |
|----------|-------|-----|------|----------|
| **Orson** | 🦁 | Male | #FF9800 | en-US-GuyNeural (friendly) |
| **Merv** | 🧙 | Male | #9C27B0 | en-US-ChristopherNeural |
| **Elli** | 🐘 | Female | #E91E63 | en-US-JennyNeural (cheerful) |
| **Bono** | 🐘 | Child | #4CAF50 | en-US-AnaNeural (cheerful) |
| **Hippo** | 🦛 | Female | #00BCD4 | en-US-AriaNeural (cheerful) |

**Структура voiceProfile в JSON:**
```json
{
  "voiceName": "en-US-GuyNeural",
  "role": null,
  "basePitch": 0,
  "baseRate": 0.95,
  "defaultStyle": "friendly",
  "defaultStyleDegree": 1.0
}
```

**Поддерживаемые языки:**
- 🇺🇸 English (en)
- 🇷🇺 Русский (ru)
- 🇩🇪 Deutsch (de)
- 🇫🇷 Français (fr)
- 🇮🇹 Italiano (it)
- 🇪🇹 Amharic (am)
- 🇲🇲 Burmese (my)

---

## 📖 Инструкция для пользователей: Как использовать Database Schema

### Получение голосового профиля персонажа

```dart
import 'package:elli_friends_app/core/database/app_database.dart';
import 'package:elli_friends_app/core/database/character_repository.dart';

// 1. Создать repository
final db = AppDatabase.instance;
final characterRepo = CharacterRepository(db);

// 2. Получить профиль для персонажа и языка
final profile = await characterRepo.getVoiceProfile('orson', 'en');
print(profile?.voiceName);    // 'en-US-GuyNeural'
print(profile?.basePitch);    // '+0%'
print(profile?.defaultStyle); // 'friendly'

// 3. Получить все профили персонажа (все языки)
final allProfiles = await characterRepo.getAllVoiceProfiles('orson');
print(allProfiles.keys); // ['en', 'ru', 'de', 'fr', 'it', 'am', 'my']

// 4. Получить локализованное имя
final name = await characterRepo.getCharacterName('orson', 'ru');
print(name); // 'Орсон Лев'
```

### Обновление голосового профиля

```dart
// Создать новый профиль
final newProfile = CharacterVoiceProfile(
  characterId: 'orson',
  languageCode: 'en',
  voiceName: 'en-US-GuyNeural',
  role: 'OlderAdultMale',
  basePitch: '-5%',
  baseRate: 0.9,
  defaultStyle: 'friendly',
  defaultStyleDegree: 1.2,
);

// Сохранить в базу
await characterRepo.updateVoiceProfile(newProfile);
```

### Редактирование characters.json

Для добавления нового персонажа, отредактируйте `assets/data/characters.json`:

```json
{
  "characterId": "new_character",
  "emoji": "🐻",
  "isChild": false,
  "isMale": true,
  "color": "#795548",
  "name": {
    "en": "Bear",
    "ru": "Медведь"
  },
  "voiceProfiles": {
    "en": {
      "voiceName": "en-US-GuyNeural",
      "basePitch": -5,
      "baseRate": 0.85,
      "defaultStyle": "friendly"
    },
    "ru": {
      "voiceName": "ru-RU-DmitryNeural",
      "basePitch": -5,
      "baseRate": 0.85
    }
  }
}
```

Затем пересоздайте базу данных (в Settings → Reset Database) или удалите файл `elli_friends.db`.

---

### ✅ Amharic Language Support — COMPLETED (2025-11-26)

#### Что было сделано:

**1. Добавлен Amharic в supported_languages.dart**

**Файл:** `lib/core/constants/supported_languages.dart`

```dart
static const List<Locale> supportedLocales = [
  // ... existing locales ...
  Locale('am', ''), // Amharic (Ethiopian)
];

static const Map<String, String> languageNames = {
  // ... existing names ...
  'am': 'አማርኛ', // Amharic
};

static const Map<String, String> ttsLanguageCodes = {
  // ... existing codes ...
  'am': 'am-ET', // Amharic
};
```

**2. Создан файл локализации app_am.arb**

**Файл:** `lib/l10n/app_am.arb`

50+ переводов интерфейса на амхарский язык:
- Навигация: "ቤት" (Home), "ትምህርቶች" (Lessons), "መቼቶች" (Settings)
- Кнопки: "ቀጣይ" (Next), "ተጫወት" (Play), "አስቀምጥ" (Save)
- Настройки: "ቋንቋ" (Language), "ድምጽ" (Sound), "ርዕስ" (Theme)
- И многое другое...

**3. Добавлены переводы диалогов в lesson_counting.json**

Все 21 диалогов переведены на амхарский:
- Title: "ከጓደኞች ጋር መቁጠር"
- Description: "ከኦርሰን እና ከሜርቭ ጋር አስቂኝ የእንስሳት ጓደኞችን በመጠቀም ከ1 እስከ 5 መቁጠር ተማር"
- Числа: "አንድ" (1), "ሁለት" (2), "ሶስት" (3), "አራት" (4), "አምስት" (5)
- Животные: "ቢራቢሮ" (butterfly), "ጦጣ" (monkey), "ወፍ" (bird), "ኤሊ" (turtle), "እንቁራሪት" (frog)

**4. Добавлены переводы диалогов в lesson_subtraction.json**

Все 19 диалогов переведены на амхарский:
- Title: "መቀነስ እንደ ደብቆ መፈለግ"
- Description: "ከኦርሰን እና ከሜርቭ ጋር ደብቆ መፈለግ ጨዋታን በመጠቀም መቀነስ ተማር"
- Фрукты: "ፖም" (apple), "ሙዝ" (banana), "ብርቱካን" (orange)
- Математика: "ሲቀነስ" (minus), "ይሆናል" (equals)

**5. Regenerated localization files**

```bash
flutter gen-l10n
```

Успешно сгенерированы файлы локализации с поддержкой амхарского.

---

#### Статистика переводов

| Файл | Записей "am" | Записей "en" | Статус |
|------|--------------|--------------|--------|
| lesson_counting.json | 23 | 23 | ✅ 100% |
| lesson_subtraction.json | 21 | 21 | ✅ 100% |
| app_am.arb | 50+ | - | ✅ Полный |

#### Важно

Для отображения нового языка и обновлённых переводов необходимо:
1. **Сбросить базу данных** (Settings → Reset Database)
2. Или удалить файл `elli_friends.db` вручную

Это перезагрузит уроки из JSON-файлов с новыми переводами.

---

### 📝 Список поддерживаемых языков (обновлено)

| Код | Язык | Флаг | TTS код | UI | Уроки |
|-----|------|------|---------|-----|-------|
| en | English | 🇺🇸 | en-US | ✅ | ✅ |
| ru | Русский | 🇷🇺 | ru-RU | ✅ | ✅ |
| fr | Français | 🇫🇷 | fr-FR | ✅ | ✅ |
| de | Deutsch | 🇩🇪 | de-DE | ✅ | ✅ |
| it | Italiano | 🇮🇹 | it-IT | ✅ | ✅ |
| **am** | **አማርኛ** | 🇪🇹 | am-ET | ✅ | ✅ |
| my | မြန်မာ | 🇲🇲 | my-MM | ✅ | ✅ |

---

### ✅ Phase 5: AzureTtsService — COMPLETED (2025-11-26)

#### Что было сделано:

**Файл:** `lib/core/services/azure_tts_service.dart`

**1. Добавлен новый метод `generateAudioWithProfile`**

Новый рекомендуемый метод для генерации аудио с двухуровневой системой настроек:

```dart
Future<Uint8List> generateAudioWithProfile({
  required String text,
  required CharacterVoiceProfile profile,
  DialogueVoiceContext? context,
}) async { ... }
```

**Особенности:**
- Принимает `CharacterVoiceProfile` для базовых настроек персонажа
- Опционально принимает `DialogueVoiceContext` для эмоциональных модификаторов
- Автоматически комбинирует pitch (сложение) и rate (умножение)
- Проверяет поддержку styles/roles для голоса
- Валидирует стиль через `AzureTtsReference.isStyleValidForVoice()`

**2. Добавлен метод `_buildAdvancedSsml`**

Генерирует полноценный SSML с поддержкой:
- `role` attribute для role-play голосов (Girl, Boy, OlderAdultMale, etc.)
- `styledegree` для интенсивности эмоций (0.01 - 2.0)
- `volume` для громкости (silent, x-soft, soft, medium, loud, x-loud)
- `<break>` для пауз до и после фразы

**3. Сохранена обратная совместимость**

Старый метод `generateAudio()` продолжает работать для существующих уроков:

```dart
// Старый способ (legacy) - работает для существующих уроков
await tts.generateAudio(
  text: "Hello!",
  languageCode: 'en',
  character: 'orson',
  emotion: 'Happy',
);

// Новый способ (рекомендуемый)
await tts.generateAudioWithProfile(
  text: "Hello!",
  profile: orsonProfile,
  context: DialogueVoiceContext.excited(),
);
```

**4. Рефакторинг HTTP-запросов**

Вынесен общий код в `_sendTtsRequest()` для избежания дублирования.

---

## 📖 Инструкция: Как использовать новый AzureTtsService

### Новый способ (рекомендуемый)

```dart
import 'package:elli_friends_app/core/services/azure_tts_service.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/character_voice_profile.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/dialogue_voice_context.dart';

// 1. Создать сервис
final tts = AzureTtsService(
  subscriptionKey: 'your-azure-key',
  region: 'eastus',
);

// 2. Создать профиль персонажа
final orsonProfile = CharacterVoiceProfile(
  characterId: 'orson',
  languageCode: 'en',
  voiceName: 'en-US-GuyNeural',
  role: 'OlderAdultMale',
  basePitch: '-5%',
  baseRate: 0.95,
  defaultStyle: 'friendly',
  defaultStyleDegree: 1.0,
);

// 3. Генерировать аудио с профилем (без контекста - используется defaultStyle)
final audio1 = await tts.generateAudioWithProfile(
  text: "Hello! I'm Orson the lion.",
  profile: orsonProfile,
);

// 4. Генерировать аудио с эмоциональным контекстом
final audio2 = await tts.generateAudioWithProfile(
  text: "That's amazing!",
  profile: orsonProfile,
  context: DialogueVoiceContext.excited(intensity: 1.5),
);

// 5. Использовать контекст из тона сцены (legacy support)
final audio3 = await tts.generateAudioWithProfile(
  text: "Hmm, let me think...",
  profile: orsonProfile,
  context: DialogueVoiceContext.fromTone('questioning'),
);
```

### Примеры сгенерированного SSML

**Английский голос с полной поддержкой:**
```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="en-US">
  <voice name="en-US-GuyNeural">
    <mstts:express-as style="excited" styledegree="1.50" role="OlderAdultMale">
      <prosody rate="+5%" pitch="+0%">
        That's amazing!
      </prosody>
    </mstts:express-as>
  </voice>
</speak>
```

**Русский голос (без стилей):**
```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="ru-RU">
  <voice name="ru-RU-DmitryNeural">
    <prosody rate="-5%" pitch="-5%">
      Привет! Я Орсон!
    </prosody>
  </voice>
</speak>
```

### Комбинирование параметров

Когда используются и профиль, и контекст:

| Параметр | Profile (базовый) | Context (модификатор) | Итог |
|----------|-------------------|----------------------|------|
| pitch | +8% | +5% | +13% (сложение) |
| rate | 0.9 | 1.1 | 0.99 (умножение) |
| style | cheerful | excited | excited (контекст приоритет) |
| styleDegree | 1.1 | 1.5 | 1.5 (контекст приоритет) |

### Работа с существующими уроками

Существующие уроки (lesson_counting.json, lesson_subtraction.json) продолжают работать через legacy API:

```dart
// Этот код НЕ нужно менять - он продолжает работать
await audioCacheService.generateSceneAudio(
  text: dialogue,
  character: 'orson',
  languageCode: 'en',
  emotion: 'Happy',
);
```

---

### Проверка изменений

Для тестирования:
1. Запустите приложение: `flutter run -d chrome`
2. Перейдите в **Settings → TTS Test**
3. Выберите персонажа и язык
4. Нажмите **Test Voice** для проверки работы TTS

Или используйте демо-страницу маскотов:
1. Запустите приложение
2. Перейдите в **Demo → Mascots**
3. Выберите персонажа и эмоцию
4. Прослушайте голос

---

### ✅ Phase 6: Character Voice Settings UI — COMPLETED (2025-11-26)

#### Что было сделано:

**1. Создан виджет VoiceSettingsPanel**

**Файл:** `lib/features/demo/widgets/voice_settings_panel.dart`

Новый виджет для настройки голосовых профилей персонажей:

```dart
class VoiceSettingsPanel extends StatefulWidget {
  final String characterId;
  final String characterEmoji;
  final String characterName;
  final VoidCallback? onProfileSaved;

  // ...
}
```

**Возможности:**
- Выбор языка (7 языков с флагами: 🇺🇸🇷🇺🇩🇪🇫🇷🇮🇹🇪🇹🇲🇲)
- Выбор голоса Azure TTS (фильтруется по языку)
- Показ количества стилей и поддержки ролей для каждого голоса
- Выбор роли (для голосов с поддержкой role-play)
- Выбор стиля по умолчанию (для голосов со стилями)
- Предупреждение если язык не поддерживает стили
- Слайдеры для настройки:
  - Pitch (-50% до +50%)
  - Rate (0.5x до 2.0x)
  - Style Intensity (0.01 до 2.0, если стиль выбран)
- Кнопка "Test Voice" для прослушивания
- Кнопка "Save" для сохранения профиля

**2. Обновлён MascotsDemo**

**Файл:** `lib/features/demo/mascots_demo.dart`

Добавлены две вкладки:
1. **Animations** — существующий функционал с Rive анимациями
2. **Voice Settings** — новый UI для настройки голосов персонажей

**Изменения:**
- Добавлен `TabController` для переключения между вкладками
- Создан класс `_VoiceSettingsTab` для управления вкладкой настроек
- Загрузка персонажей из `CharacterRepository`
- Выбор персонажа через интерактивные карточки с эмодзи и цветом
- Интеграция с `VoiceSettingsPanel`

**3. Интеграция с существующей архитектурой**

- Использует `CharacterRepository` для загрузки и сохранения профилей
- Использует `AzureTtsReference` для получения списка голосов и их возможностей
- Использует `AzureTtsService.generateAudioWithProfile()` для тестирования голоса
- Полная обратная совместимость с существующими уроками

---

## 📖 Инструкция для пользователей: Character Voice Settings

### Как открыть настройки голоса

1. Запустите приложение
2. Перейдите на страницу **Character Studio** (бывшая Mascots Demo)
3. Нажмите на вкладку **Voice Settings**

### Интерфейс настроек

```
┌─────────────────────────────────────────────────────────────┐
│  Character Studio                [Animations] [Voice Settings]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Select Character                                           │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │ 🦁      │ │ 🧙      │ │ 🐘      │ │ 🐘      │ │ 🦛      ││
│  │ Orson   │ │ Merv    │ │ Elli    │ │ Bono    │ │ Hippo   ││
│  │ Male    │ │ Male    │ │ Female  │ │ Child   │ │ Female  ││
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘│
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 🦁 🔊 Voice Settings                                    ││
│  ├─────────────────────────────────────────────────────────┤│
│  │ Language                                                ││
│  │ [🇺🇸 EN] [🇷🇺 RU] [🇩🇪 DE] [🇫🇷 FR] [🇮🇹 IT] [🇪🇹 AM] [🇲🇲 MY] ││
│  │                                                         ││
│  │ Voice                                                   ││
│  │ ┌─────────────────────────────────────────────────────┐ ││
│  │ │ Guy (Male)  [10 styles] [roles]              ▼     │ ││
│  │ └─────────────────────────────────────────────────────┘ ││
│  │                                                         ││
│  │ Role                                                    ││
│  │ ┌─────────────────────────────────────────────────────┐ ││
│  │ │ Older Adult Male                             ▼     │ ││
│  │ └─────────────────────────────────────────────────────┘ ││
│  │                                                         ││
│  │ Default Style                                           ││
│  │ ┌─────────────────────────────────────────────────────┐ ││
│  │ │ Friendly                                     ▼     │ ││
│  │ └─────────────────────────────────────────────────────┘ ││
│  │                                                         ││
│  │ Prosody                                                 ││
│  │ Pitch          ──────────●────── 0%                    ││
│  │ Rate           ────────●──────── 0.95x                 ││
│  │ Style Intensity────────────●──── 1.00                  ││
│  │                                                         ││
│  │ [▶ Test Voice]                             [💾 Save]   ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Порядок настройки голоса персонажа

1. **Выберите персонажа** из списка карточек вверху
2. **Выберите язык** — кликните на нужный флаг (🇺🇸🇷🇺🇩🇪🇫🇷🇮🇹🇪🇹🇲🇲)
3. **Выберите голос** — в dropdown показаны голоса для этого языка
   - Рядом с голосом показано количество стилей и поддержка ролей
4. **Настройте роль** (если голос поддерживает) — Girl, Boy, OlderAdultMale, etc.
5. **Выберите стиль по умолчанию** (если голос поддерживает) — cheerful, friendly, etc.
6. **Настройте просодию** слайдерами:
   - **Pitch** — высота голоса (-50% до +50%)
   - **Rate** — скорость речи (0.5x до 2.0x)
   - **Style Intensity** — интенсивность эмоций (0.01 до 2.0)
7. **Нажмите "Test Voice"** для прослушивания
8. **Нажмите "Save"** для сохранения профиля

### Особенности по языкам

| Язык | Голоса со стилями | Голоса с ролями |
|------|-------------------|-----------------|
| 🇺🇸 English | Jenny, Guy, Aria, Ana | Jenny, Guy, Aria |
| 🇷🇺 Русский | — | — |
| 🇩🇪 Deutsch | Katja, Conrad | — |
| 🇫🇷 Français | Denise, Henri | — |
| 🇮🇹 Italiano | Isabella | — |
| 🇪🇹 Amharic | — | — |
| 🇲🇲 Burmese | — | — |

Для языков без поддержки стилей отображается предупреждение.

### Важно

- Настройки сохраняются **отдельно для каждого языка** персонажа
- При переключении языка загружается сохранённый профиль для этого языка
- Если профиль не настроен — используются значения по умолчанию из `characters.json`
- Для тестирования голоса требуется **Azure TTS API ключ** (переменная окружения `AZURE_TTS_KEY`)

### Требования для Test Voice

Для работы кнопки "Test Voice" необходимо:

1. Получить Azure Speech Services API ключ
2. Установить переменные окружения:
   ```bash
   export AZURE_TTS_KEY="your-subscription-key"
   export AZURE_TTS_REGION="eastus"  # или другой регион
   ```
3. Или передать при запуске:
   ```bash
   flutter run --dart-define=AZURE_TTS_KEY=your-key --dart-define=AZURE_TTS_REGION=eastus
   ```

---

## Как работает интеграция (Phase 7)

### Архитектура аудио системы

```
┌─────────────────────────────────────────────────────────────┐
│                      LessonPage                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  _initializeAudio()                                  │   │
│  │    → AudioManager.initialize(languageCode)           │   │
│  │    → AudioManager.setCharacterRepository(repo)       │   │
│  │    → AudioManager.loadVoiceProfiles()               │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  _playScene(scene)                                   │   │
│  │    → speakDialogue(text, character, tone)            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      AudioManager                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  speakDialogue(text, character, tone)                │   │
│  │    1. Try cached audio (AudioCacheService)           │   │
│  │    2. Try Azure TTS (with voice profile + tone)      │   │
│  │    3. Fallback to system TTS                         │   │
│  └──────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  _speakWithAzureTts(text, profile, context)          │   │
│  │    → AzureTtsService.generateAudioWithProfile()      │   │
│  │    → _voicePlayer.play(BytesSource(audioData))       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Как tone из урока превращается в голосовые настройки

1. **Урок JSON содержит tone:**
   ```json
   {
     "character": "orson",
     "dialogue": { "en": "Hello!" },
     "tone": "excited"
   }
   ```

2. **LessonPage передаёт tone в AudioManager:**
   ```dart
   await _audioManager.speakDialogue(
     scene.dialogue!,
     character: scene.character!,
     tone: scene.tone,  // "excited"
   );
   ```

3. **AudioManager создаёт DialogueVoiceContext:**
   ```dart
   final context = DialogueVoiceContext.fromTone(tone);
   // excited → style="excited", styleDegree=1.3, pitch=+5%, rate=1.1
   ```

4. **AzureTtsService комбинирует profile + context:**
   ```dart
   // Profile: voiceName=en-US-JennyNeural, basePitch=+8%, baseRate=0.9
   // Context: style=excited, pitchMod=+5%, rateMod=1.1
   // Result: pitch=+13%, rate=0.99, style=excited
   ```

5. **Генерируется SSML:**
   ```xml
   <speak version="1.0" xml:lang="en-US">
     <voice name="en-US-JennyNeural">
       <mstts:express-as style="excited" styledegree="1.3">
         <prosody rate="-1%" pitch="+13%">
           Hello!
         </prosody>
       </mstts:express-as>
     </voice>
   </speak>
   ```

### Fallback система

Если Azure TTS недоступен (нет ключа, сетевая ошибка):

```
speakDialogue()
    │
    ├── 1. Cached audio? → Play from file
    │
    ├── 2. Azure TTS available? → Generate + Play
    │       └── Error? → Continue to fallback
    │
    └── 3. System TTS (flutter_tts)
            └── Uses character-specific pitch/rate settings
```

### Поддерживаемые tone значения

| tone | style | styleDegree | pitch | rate |
|------|-------|-------------|-------|------|
| excited | excited | 1.3 | +5% | 1.1 |
| cheerful/happy | cheerful | 1.2 | — | — |
| sad | sad | 1.2 | -5% | 0.85 |
| angry | angry | 1.3 | +3% | 1.1 |
| calm/gentle | friendly | — | — | 0.9 |
| questioning/curious | friendly | — | +10% | — |
| whisper | whispering | — | — | 0.85 |
| shout | shouting | — | +10% | 1.15 |
| friendly | friendly | — | — | — |
| neutral | — | — | — | — |

---
