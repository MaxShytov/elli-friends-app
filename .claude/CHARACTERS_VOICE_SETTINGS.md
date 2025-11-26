# Character Voice Settings - Implementation Documentation

**Дата создания:** 2025-11-26
**Версия:** 1.0

---

## Research

### Обзор текущей архитектуры голосовых настроек

Система голосовых настроек персонажей реализована по **двухуровневой архитектуре**:

```
┌─────────────────────────────────────────────────────┐
│              🎭 АКТЁР (CharacterVoiceProfile)       │
│  Базовые настройки голоса для персонажа             │
│  ┌───────────────────────────────────────────────┐  │
│  │  • characterId    (orson, elli, bono...)      │  │
│  │  • languageCode   (en, ru, de, fr...)         │  │
│  │  • voiceName      (en-US-JennyNeural)         │  │
│  │  • role           (Girl, Boy, OlderAdultMale) │  │
│  │  • basePitch      (+8%, -5%, 0%)              │  │
│  │  • baseRate       (0.5 - 2.0)                 │  │
│  │  • defaultStyle   (friendly, cheerful)        │  │
│  │  • defaultStyleDegree (0.01 - 2.0)            │  │
│  └───────────────────────────────────────────────┘  │
│                         │                           │
│                         ▼                           │
│  ┌───────────────────────────────────────────────┐  │
│  │         🎬 ФРАЗА (DialogueVoiceContext)       │  │
│  │  Эмоциональные модификаторы для конкретной    │  │
│  │  реплики (переопределяют базовые настройки)   │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │  • style        (excited, sad, angry)   │  │  │
│  │  │  • styleDegree  (0.01 - 2.0)            │  │  │
│  │  │  • pitchModifier (+5%, -3%)             │  │  │
│  │  │  • rateModifier  (0.8, 1.2)             │  │  │
│  │  │  • volume       (soft, medium, loud)    │  │  │
│  │  │  • breakBefore  (pause in ms)           │  │  │
│  │  │  • breakAfter   (pause in ms)           │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
                         │
                         ▼
              ┌─────────────────┐
              │  Azure TTS SSML │
              └─────────────────┘
```

---

### Ключевые файлы реализации

#### 1. Domain Models (Entities)

| Файл | Описание |
|------|----------|
| [character_voice_profile.dart](lib/features/lessons/domain/entities/character_voice_profile.dart) | Модель профиля голоса персонажа (уровень "Актёр") |
| [dialogue_voice_context.dart](lib/features/lessons/domain/entities/dialogue_voice_context.dart) | Контекст голоса для конкретной фразы (уровень "Фраза") |

#### 2. Reference Data

| Файл | Описание |
|------|----------|
| [azure_tts_reference.dart](lib/core/services/azure_tts_reference.dart) | Справочные данные Azure TTS (голоса, стили, лимиты параметров) |

#### 3. Services

| Файл | Описание |
|------|----------|
| [azure_tts_service.dart](lib/core/services/azure_tts_service.dart) | Сервис генерации аудио через Azure TTS API |
| [audio_manager.dart](lib/core/services/audio_manager.dart) | Централизованный менеджер аудио (TTS + SFX + Music) |

#### 4. Data Storage

| Файл | Описание |
|------|----------|
| [characters.json](assets/data/characters.json) | JSON с seed-данными персонажей и их голосовыми профилями |
| [app_database.dart](lib/core/database/app_database.dart) | Drift база данных с таблицей Characters |
| [character_repository.dart](lib/core/database/character_repository.dart) | Репозиторий для работы с персонажами в БД |
| [seed_service.dart](lib/core/database/seed_service.dart) | Сервис начальной загрузки данных в БД |

#### 5. UI Components

| Файл | Описание |
|------|----------|
| [voice_settings_panel.dart](lib/features/demo/widgets/voice_settings_panel.dart) | Панель настройки голоса в MascotsDemo |
| [mascots_demo.dart](lib/features/demo/mascots_demo.dart) | Демо-страница с настройкой голосов персонажей |

---

### Детальное описание моделей данных

#### CharacterVoiceProfile

Базовые настройки голоса для персонажа в конкретном языке. Каждый персонаж имеет отдельный профиль для каждого поддерживаемого языка.

```dart
class CharacterVoiceProfile {
  final String characterId;        // ID персонажа: "orson", "elli", "bono"
  final String languageCode;       // Код языка: "en", "ru", "de"
  final String voiceName;          // Azure голос: "en-US-JennyNeural"
  final String? role;              // Role-play: "Girl", "Boy" (только для en-US)
  final String basePitch;          // Базовый pitch: "+8%", "-5%", "0%"
  final double baseRate;           // Базовая скорость: 0.5 - 2.0
  final String? defaultStyle;      // Стиль по умолчанию: "cheerful", "friendly"
  final double defaultStyleDegree; // Интенсивность стиля: 0.01 - 2.0
}
```

**Ключевые методы:**
- `combinePitch(modifier)` - комбинирует базовый pitch с модификатором из DialogueVoiceContext
- `combineRate(modifier)` - комбинирует базовую скорость с модификатором (мультипликативно)
- `getEffectiveStyle(contextStyle)` - возвращает итоговый стиль (из контекста или default)
- `supportsStyles` / `supportsRole` - проверка поддержки функций голосом

#### DialogueVoiceContext

Эмоциональные модификаторы для конкретной реплики. Комбинируются с CharacterVoiceProfile.

```dart
class DialogueVoiceContext {
  final String? style;           // Эмоция: "excited", "sad", "angry"
  final double? styleDegree;     // Интенсивность: 0.01 - 2.0
  final String? pitchModifier;   // Модификатор pitch: "+10%", "-5%"
  final double? rateModifier;    // Модификатор скорости: 0.8, 1.2
  final String? volume;          // Громкость: "soft", "medium", "loud"
  final int? breakBefore;        // Пауза перед (мс)
  final int? breakAfter;         // Пауза после (мс)
}
```

**Factory методы для частых эмоций:**
- `DialogueVoiceContext.excited()` - возбуждённая речь
- `DialogueVoiceContext.cheerful()` - весёлая речь
- `DialogueVoiceContext.sad()` - грустная речь
- `DialogueVoiceContext.angry()` - злая речь
- `DialogueVoiceContext.calm()` - спокойная речь
- `DialogueVoiceContext.whisper()` - шёпот
- `DialogueVoiceContext.shout()` - крик
- `DialogueVoiceContext.fromTone(String tone)` - создание из строки тона (legacy)

---

### Поддерживаемые голоса Azure TTS

Данные хранятся в `AzureTtsReference.voicesByLanguage`:

| Язык | Голоса | Стили | Роли |
|------|--------|-------|------|
| **en** (English) | Jenny, Guy, Aria, Ana, Christopher, Eric, Michelle, Roger | ✅ (Jenny, Guy, Aria, Ana) | ✅ (Jenny, Guy, Aria) |
| **ru** (Русский) | Svetlana, Dmitry, Dariya | ❌ | ❌ |
| **de** (Deutsch) | Katja, Conrad, Gisela, Killian, Amala | ⚠️ (Katja, Conrad) | ❌ |
| **fr** (Français) | Denise, Henri, Eloise, Alain, Brigitte | ⚠️ (Denise, Henri) | ❌ |
| **it** (Italiano) | Elsa, Isabella, Diego, Giuseppe, Pierina | ⚠️ (Isabella) | ❌ |
| **am** (Amharic) | Mekdes, Ameha | ❌ | ❌ |
| **my** (Burmese) | Nilar, Thiha | ❌ | ❌ |

**Легенда:**
- ✅ = полная поддержка (много стилей)
- ⚠️ = ограниченная поддержка (несколько стилей)
- ❌ = не поддерживается

---

### Текущие персонажи и их голосовые профили

Данные загружаются из `assets/data/characters.json`:

| Персонаж | Emoji | Тип | EN Voice | RU Voice | Особенности |
|----------|-------|-----|----------|----------|-------------|
| **Orson** | 🦁 | Adult Male | Guy Neural | Dmitry Neural | friendly style, rate 0.95 |
| **Merv** | 🧙 | Adult Male | Christopher Neural | Dmitry Neural | pitch +5%, rate 0.9 |
| **Elli** | 🐘 | Adult Female | Jenny Neural (role: Girl) | Svetlana Neural | pitch +8%, cheerful style |
| **Bono** | 🐘 | Child | Ana Neural | Dariya Neural | pitch +15%, rate 1.05, cheerful |
| **Hippo** | 🦛 | Adult Female | Aria Neural | Svetlana Neural | pitch +3%, cheerful style |

---

### Генерация SSML

`AzureTtsService.generateAudioWithProfile()` создаёт SSML на основе профиля и контекста:

**Пример для английского голоса с поддержкой стилей:**
```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="en-US">
  <voice name="en-US-JennyNeural">
    <mstts:express-as style="cheerful" styledegree="1.30" role="Girl">
      <prosody rate="+5%" pitch="+13%">
        Look! One, two, three apples!
      </prosody>
    </mstts:express-as>
  </voice>
</speak>
```

**Пример для русского голоса (без стилей):**
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

### Поток данных при воспроизведении голоса

```
1. LessonPage инициализирует AudioManager
   ↓
2. AudioManager.loadVoiceProfiles() загружает профили из CharacterRepository
   ↓
3. При воспроизведении диалога:
   - Scene содержит character и tone
   - AudioManager.speakDialogue(text, character, tone)
   ↓
4. Если Azure TTS доступен:
   - Получаем CharacterVoiceProfile для персонажа и языка
   - Создаём DialogueVoiceContext из tone
   - Вызываем AzureTtsService.generateAudioWithProfile()
   - Воспроизводим MP3 аудио
   ↓
5. Fallback: используем системный TTS (flutter_tts)
```

---

### UI для настройки голосов

Реализован в `MascotsDemo` + `VoiceSettingsPanel`:

```
┌─────────────────────────────────────────────────────────────┐
│  🎭 Character Voice Settings                                 │
├─────────────────────────────────────────────────────────────┤
│  [Rive Animation Character Preview]                         │
│                                                             │
│  Character: [Orson ▼] [Merv] [Elli] [Bono] [Hippo]          │
│  Emotions: [😊 Happy] [😢 Sad] [😠 Angry] [🤩 Excited]       │
│                                                             │
│  ═══════════════════ Voice Settings ════════════════════    │
│                                                             │
│  Language:  [🇺🇸 English ▼]                                  │
│  Voice:     [Jenny Neural (Female) ▼]                       │
│             ℹ️ 14 styles available                           │
│  Role:      [Girl ▼]  (если голос поддерживает)             │
│  Style:     [Friendly ▼]                                    │
│                                                             │
│  Pitch:     ──────●────── +8%                               │
│  Rate:      ────●──────── 1.0x                              │
│  StyleDeg:  ──────────●── 1.1                               │
│                                                             │
│  Test: "Hello! I'm Elli the elephant."                      │
│                                                             │
│  [▶ Test Voice]                      [💾 Save for Language]  │
└─────────────────────────────────────────────────────────────┘
```

---

### Статус реализации (из VOICE_CURRENT_TASK.md)

| Фаза | Описание | Статус |
|------|----------|--------|
| Phase 1 | Azure TTS Reference Data | ✅ Completed |
| Phase 2 | Domain Models (CharacterVoiceProfile, DialogueVoiceContext) | ✅ Completed |
| Phase 3 | Database Schema (Characters table, voiceContextJson) | ✅ Completed |
| Phase 4 | Seed Data (5 персонажей, 7 языков) | ✅ Completed |
| Phase 5 | AzureTtsService (generateAudioWithProfile) | ✅ Completed |
| Phase 6 | UI (VoiceSettingsPanel в MascotsDemo) | ✅ Completed |
| Phase 7 | Integration (AudioManager + LessonPage) | ✅ Completed |
| Phase 8 | Hybrid Audio System (CLI + pre-bundled assets) | ❌ Pending |
| Phase 9 | Tests | ❌ Pending |

---

### Важные особенности

1. **Обратная совместимость**: Если Azure TTS недоступен, система fallback на системный TTS (flutter_tts)

2. **Валидация стилей**: Стили проверяются на совместимость с голосом через `AzureTtsReference.isStyleValidForVoice()`

3. **Роли (role-play)**: Поддерживаются только для en-US голосов (Jenny, Guy, Aria)

4. **Комбинирование параметров**:
   - Pitch: базовый + модификатор (additive)
   - Rate: базовый × модификатор (multiplicative)
   - Style: контекст переопределяет default

5. **Поддержка пауз**: breakBefore/breakAfter в DialogueVoiceContext добавляют SSML `<break>` теги

---

## TODO

- [ ] Реализовать SceneVoiceContextPicker для SceneEditorDialog
- [ ] Добавить CLI tool для предварительной генерации аудио
- [ ] Реализовать HybridAudioService (pre-bundled + on-demand)
- [ ] Написать unit/widget тесты

---

## Ссылки

- [Azure TTS Documentation](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/speech-synthesis-markup)
- [SSML Reference](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/speech-synthesis-markup-voice)
- [Voice Styles](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support?tabs=tts#voice-styles-and-roles)

---

## Plan: Оптимальные голосовые настройки для Orson и Merv

**Дата:** 2025-11-26
**Статус:** PHASE 1-4 COMPLETED, PHASE 5+ PENDING

### Цель

Предзаполнить систему настройками голосов для персонажей Orson и Merv:
1. Orson = мальчик (если есть различие мужской/женский), Merv = девочка (или два разных голоса)
2. Style = Friendly (или максимально близкий)
3. Pitch, Rate, Style Intensity оптимизированы для детей 5-7 лет
4. Настройки сохраняются как seed/default и могут быть сброшены по нажатию Reset

---

### PHASE 1: Анализ и выбор оптимальных голосов для каждого языка

> **COMPLETED** (2025-11-26): Анализ выполнен, голоса выбраны согласно таблице ниже.

#### Задача 1.1: Определить оптимальные голоса Azure TTS

Для каждого языка нужно выбрать:
- **Orson** (🦁 лев, взрослый мужчина) — мужской голос
- **Merv** (🧙 волшебник) — женский голос для контраста

**Таблица оптимальных голосов:**

| Язык | Orson (Male) | Merv (Female) | Стили поддержаны? |
|------|--------------|---------------|-------------------|
| **en** | Guy (friendly style) | Jenny + role Girl (friendly) | ✅ да |
| **ru** | Dmitry | Svetlana | ❌ нет |
| **de** | Conrad (cheerful) | Katja (cheerful) | ⚠️ частично |
| **fr** | Henri (cheerful) | Denise (cheerful) | ⚠️ частично |
| **it** | Diego | Isabella (cheerful) | ⚠️ частично |
| **am** | Ameha | Mekdes | ❌ нет |
| **my** | Thiha | Nilar | ❌ нет |

#### Задача 1.2: Определить оптимальные параметры для детей 5-7 лет

**Рекомендуемые значения:**

| Параметр | Orson (лев) | Merv (волшебница) | Обоснование |
|----------|-------------|-------------------|-------------|
| **basePitch** | `+0%` | `+5%` | Чуть выше для женского персонажа |
| **baseRate** | `0.90` | `0.88` | Медленнее для детей, Merv мистическая |
| **defaultStyle** | `friendly` | `friendly` | Или cheerful если friendly недоступен |
| **defaultStyleDegree** | `1.1` | `1.2` | Чуть выше для выразительности |

---

### PHASE 2: Обновление characters.json (Seed Data)

> **COMPLETED** (2025-11-26): characters.json обновлён. Orson и Merv используют оптимизированные голоса.

#### Задача 2.1: Обновить voiceProfiles для Orson

**Файл:** `assets/data/characters.json`

**Изменения для Orson:**
```json
{
  "characterId": "orson",
  "isMale": true,
  "voiceProfiles": {
    "en": {
      "voiceName": "en-US-GuyNeural",
      "role": null,
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": "friendly",
      "defaultStyleDegree": 1.1
    },
    "ru": {
      "voiceName": "ru-RU-DmitryNeural",
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    },
    "de": {
      "voiceName": "de-DE-ConradNeural",
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": "cheerful",
      "defaultStyleDegree": 1.1
    },
    "fr": {
      "voiceName": "fr-FR-HenriNeural",
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": "cheerful",
      "defaultStyleDegree": 1.1
    },
    "it": {
      "voiceName": "it-IT-DiegoNeural",
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    },
    "am": {
      "voiceName": "am-ET-AmehaNeural",
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    },
    "my": {
      "voiceName": "my-MM-ThihaNeural",
      "basePitch": 0,
      "baseRate": 0.90,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    }
  }
}
```

**Проверка:** Запустить приложение, проверить что Orson использует правильные голоса.

---

#### Задача 2.2: Обновить voiceProfiles для Merv (изменить на женский голос)

**Текущее состояние Merv:** `isMale: true` (два мужских голоса)

**Новое состояние Merv:** `isMale: false` (женский голос для контраста)

```json
{
  "characterId": "merv",
  "emoji": "🧙",
  "isMale": false,
  "voiceProfiles": {
    "en": {
      "voiceName": "en-US-JennyNeural",
      "role": "Girl",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": "friendly",
      "defaultStyleDegree": 1.2
    },
    "ru": {
      "voiceName": "ru-RU-SvetlanaNeural",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    },
    "de": {
      "voiceName": "de-DE-KatjaNeural",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": "cheerful",
      "defaultStyleDegree": 1.2
    },
    "fr": {
      "voiceName": "fr-FR-DeniseNeural",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": "cheerful",
      "defaultStyleDegree": 1.2
    },
    "it": {
      "voiceName": "it-IT-IsabellaNeural",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": "cheerful",
      "defaultStyleDegree": 1.2
    },
    "am": {
      "voiceName": "am-ET-MekdesNeural",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    },
    "my": {
      "voiceName": "my-MM-NilarNeural",
      "basePitch": 5,
      "baseRate": 0.88,
      "defaultStyle": null,
      "defaultStyleDegree": 1.0
    }
  }
}
```

**Проверка:** Запустить приложение, проверить что Merv использует женские голоса.

---

### PHASE 3: Добавить функцию Reset to Default

> **COMPLETED** (2025-11-26): Реализовано: default_voice_profiles.json, методы reset в CharacterRepository, кнопка Reset в UI.

#### Задача 3.1: Создать default_voice_profiles.json

**Файл:** `assets/data/default_voice_profiles.json` (новый)

Содержит "заводские" настройки для каждого персонажа, которые используются при Reset.

```json
{
  "orson": {
    "en": { "voiceName": "en-US-GuyNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": "friendly", "defaultStyleDegree": 1.1 },
    "ru": { "voiceName": "ru-RU-DmitryNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": null, "defaultStyleDegree": 1.0 },
    "de": { "voiceName": "de-DE-ConradNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": "cheerful", "defaultStyleDegree": 1.1 },
    "fr": { "voiceName": "fr-FR-HenriNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": "cheerful", "defaultStyleDegree": 1.1 },
    "it": { "voiceName": "it-IT-DiegoNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": null, "defaultStyleDegree": 1.0 },
    "am": { "voiceName": "am-ET-AmehaNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": null, "defaultStyleDegree": 1.0 },
    "my": { "voiceName": "my-MM-ThihaNeural", "role": null, "basePitch": 0, "baseRate": 0.90, "defaultStyle": null, "defaultStyleDegree": 1.0 }
  },
  "merv": {
    "en": { "voiceName": "en-US-JennyNeural", "role": "Girl", "basePitch": 5, "baseRate": 0.88, "defaultStyle": "friendly", "defaultStyleDegree": 1.2 },
    "ru": { "voiceName": "ru-RU-SvetlanaNeural", "role": null, "basePitch": 5, "baseRate": 0.88, "defaultStyle": null, "defaultStyleDegree": 1.0 },
    "de": { "voiceName": "de-DE-KatjaNeural", "role": null, "basePitch": 5, "baseRate": 0.88, "defaultStyle": "cheerful", "defaultStyleDegree": 1.2 },
    "fr": { "voiceName": "fr-FR-DeniseNeural", "role": null, "basePitch": 5, "baseRate": 0.88, "defaultStyle": "cheerful", "defaultStyleDegree": 1.2 },
    "it": { "voiceName": "it-IT-IsabellaNeural", "role": null, "basePitch": 5, "baseRate": 0.88, "defaultStyle": "cheerful", "defaultStyleDegree": 1.2 },
    "am": { "voiceName": "am-ET-MekdesNeural", "role": null, "basePitch": 5, "baseRate": 0.88, "defaultStyle": null, "defaultStyleDegree": 1.0 },
    "my": { "voiceName": "my-MM-NilarNeural", "role": null, "basePitch": 5, "baseRate": 0.88, "defaultStyle": null, "defaultStyleDegree": 1.0 }
  }
}
```

**Проверка:** Проверить что файл корректно парсится.

---

#### Задача 3.2: Обновить CharacterRepository

**Файл:** `lib/core/database/character_repository.dart`

Добавить методы:

```dart
/// Reset voice profile for character/language to default values
Future<void> resetVoiceProfileToDefault(
  String characterId,
  String languageCode,
) async {
  final defaultProfile = await _loadDefaultProfile(characterId, languageCode);
  if (defaultProfile != null) {
    await updateVoiceProfile(defaultProfile);
    debugPrint(
      'CharacterRepository: Reset ${characterId}/${languageCode} to default',
    );
  }
}

/// Reset all voice profiles for a character to defaults
Future<void> resetAllVoiceProfilesToDefault(String characterId) async {
  final defaults = await _loadAllDefaultProfiles(characterId);
  for (final profile in defaults) {
    await updateVoiceProfile(profile);
  }
}

/// Load default profile from assets
Future<CharacterVoiceProfile?> _loadDefaultProfile(
  String characterId,
  String languageCode,
) async {
  final jsonString = await rootBundle.loadString(
    'assets/data/default_voice_profiles.json',
  );
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final charDefaults = data[characterId] as Map<String, dynamic>?;
  if (charDefaults == null) return null;

  final langDefaults = charDefaults[languageCode] as Map<String, dynamic>?;
  if (langDefaults == null) return null;

  return CharacterVoiceProfile.fromVoiceJson(
    characterId: characterId,
    languageCode: languageCode,
    json: langDefaults,
  );
}

/// Load all default profiles for a character
Future<List<CharacterVoiceProfile>> _loadAllDefaultProfiles(
  String characterId,
) async {
  final jsonString = await rootBundle.loadString(
    'assets/data/default_voice_profiles.json',
  );
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final charDefaults = data[characterId] as Map<String, dynamic>?;
  if (charDefaults == null) return [];

  final profiles = <CharacterVoiceProfile>[];
  for (final entry in charDefaults.entries) {
    final langCode = entry.key;
    final langDefaults = entry.value as Map<String, dynamic>;
    profiles.add(CharacterVoiceProfile.fromVoiceJson(
      characterId: characterId,
      languageCode: langCode,
      json: langDefaults,
    ));
  }
  return profiles;
}
```

**Проверка:**
1. Изменить настройки персонажа через UI
2. Вызвать `resetVoiceProfileToDefault`
3. Проверить, что настройки вернулись к default

---

#### Задача 3.3: Добавить кнопку Reset в VoiceSettingsPanel

**Файл:** `lib/features/demo/widgets/voice_settings_panel.dart`

Добавить метод:

```dart
Future<void> _resetToDefault() async {
  setState(() => _isLoading = true);
  try {
    await _characterRepo.resetVoiceProfileToDefault(
      widget.characterId,
      _selectedLanguage,
    );
    await _loadProfile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset to default settings'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  } catch (e) {
    setState(() => _error = 'Reset failed: $e');
  }
}
```

В `_buildActionButtons` добавить кнопку Reset:

```dart
Row(
  children: [
    // Reset button
    IconButton(
      icon: const Icon(Icons.restore),
      tooltip: 'Reset to Default',
      onPressed: _isLoading ? null : _resetToDefault,
    ),
    const Spacer(),
    // Existing Test and Save buttons...
  ],
)
```

**Проверка:**
1. Открыть VoiceSettingsPanel
2. Изменить параметры (pitch, rate, style)
3. Нажать Save
4. Нажать Reset
5. Проверить, что значения вернулись к оптимальным для детей

---

### PHASE 4: Проверить SeedService

> **COMPLETED** (2025-11-26): SeedService уже корректно читает characters.json. Проверено: basePitch конвертируется в строку, все поля сохраняются.

#### Задача 4.1: Убедиться что SeedService использует обновлённые данные

**Файл:** `lib/core/database/seed_service.dart`

SeedService уже читает данные из `assets/data/characters.json`, поэтому после обновления characters.json новые настройки автоматически применятся при первом запуске.

**Ключевые моменты реализации:**
- `_seedCharacters()` читает из `assets/data/characters.json`
- basePitch конвертируется из int (0, 5) в string ("+0%", "+5%") в строках 79-81
- `resetCharacters()` позволяет пересоздать персонажей из assets
- `resetAndReseed()` полностью пересоздаёт БД

**Проверка:**
1. Удалить базу данных (очистить данные приложения или удалить app_database.db)
2. Запустить приложение
3. Проверить в MascotsDemo что Orson имеет мужской голос с friendly стилем
4. Проверить что Merv имеет женский голос с friendly стилем

---

### PHASE 5: Тестирование

#### Задача 5.1: Unit тесты для CharacterRepository

**Файл:** `test/unit/core/database/character_repository_test.dart` (новый)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/core/database/character_repository.dart';

void main() {
  group('CharacterRepository Voice Profiles', () {
    late CharacterRepository repo;

    setUp(() async {
      // Initialize test database with seed data
      repo = CharacterRepository(testDb);
    });

    test('getVoiceProfile returns correct profile for Orson EN', () async {
      final profile = await repo.getVoiceProfile('orson', 'en');

      expect(profile, isNotNull);
      expect(profile!.voiceName, 'en-US-GuyNeural');
      expect(profile.baseRate, 0.90);
      expect(profile.defaultStyle, 'friendly');
      expect(profile.defaultStyleDegree, 1.1);
    });

    test('getVoiceProfile returns correct profile for Merv EN', () async {
      final profile = await repo.getVoiceProfile('merv', 'en');

      expect(profile, isNotNull);
      expect(profile!.voiceName, 'en-US-JennyNeural');
      expect(profile.role, 'Girl');
      expect(profile.baseRate, 0.88);
      expect(profile.defaultStyle, 'friendly');
      expect(profile.defaultStyleDegree, 1.2);
    });

    test('resetVoiceProfileToDefault restores original values', () async {
      // Modify profile
      await repo.updateVoiceProfile(
        CharacterVoiceProfile(
          characterId: 'orson',
          languageCode: 'en',
          voiceName: 'en-US-JennyNeural', // Wrong voice
          basePitch: '+50%',
          baseRate: 2.0,
          defaultStyleDegree: 0.5,
        ),
      );

      // Verify modification
      var profile = await repo.getVoiceProfile('orson', 'en');
      expect(profile!.voiceName, 'en-US-JennyNeural');

      // Reset
      await repo.resetVoiceProfileToDefault('orson', 'en');

      // Verify reset
      profile = await repo.getVoiceProfile('orson', 'en');
      expect(profile!.voiceName, 'en-US-GuyNeural');
      expect(profile.baseRate, 0.90);
      expect(profile.defaultStyle, 'friendly');
    });
  });
}
```

**Проверка:** `flutter test test/unit/core/database/character_repository_test.dart`

---

#### Задача 5.2: Widget тесты для VoiceSettingsPanel

**Файл:** `test/widget/features/demo/voice_settings_panel_test.dart` (новый)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/features/demo/widgets/voice_settings_panel.dart';

void main() {
  group('VoiceSettingsPanel', () {
    testWidgets('displays Reset button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VoiceSettingsPanel(
              characterId: 'orson',
              characterEmoji: '🦁',
              characterName: 'Orson',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('Reset button has correct tooltip', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VoiceSettingsPanel(
              characterId: 'orson',
              characterEmoji: '🦁',
              characterName: 'Orson',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final iconButton = tester.widget<IconButton>(find.byIcon(Icons.restore));
      expect(iconButton.tooltip, 'Reset to Default');
    });
  });
}
```

**Проверка:** `flutter test test/widget/features/demo/voice_settings_panel_test.dart`

---

#### Задача 5.3: Интеграционное тестирование (ручное)

**Чек-лист для ручного тестирования:**

- [ ] Запустить приложение с чистой БД
- [ ] Открыть MascotsDemo, выбрать Orson
- [ ] Проверить EN: Voice = Guy, Rate = 0.90, Style = friendly
- [ ] Проверить RU: Voice = Dmitry, Rate = 0.90, Style = none
- [ ] Нажать Test Voice — должен быть понятный медленный голос
- [ ] Выбрать Merv
- [ ] Проверить EN: Voice = Jenny, Role = Girl, Rate = 0.88, Style = friendly
- [ ] Проверить RU: Voice = Svetlana, Rate = 0.88, Style = none
- [ ] Нажать Test Voice — должен быть женский понятный голос
- [ ] Изменить настройки Orson (pitch +30%, rate 1.5), сохранить
- [ ] Нажать Reset
- [ ] Проверить что настройки вернулись к default (pitch 0%, rate 0.90)
- [ ] Проверить Test Voice для de, fr, it, am, my языков

---

## Порядок выполнения

1. **Phase 2.1-2.2**: Обновить `characters.json` — это основа
2. **Phase 4.1**: Проверить что SeedService работает с новыми данными
3. **Phase 3.1**: Создать `default_voice_profiles.json`
4. **Phase 3.2**: Добавить методы reset в CharacterRepository
5. **Phase 3.3**: Добавить кнопку Reset в UI
6. **Phase 5**: Написать тесты

---

## Файлы для изменения

| # | Файл | Изменение | Приоритет |
|---|------|-----------|-----------|
| 1 | `assets/data/characters.json` | Обновить voiceProfiles для Orson и Merv | HIGH |
| 2 | `assets/data/default_voice_profiles.json` | Создать (новый) | HIGH |
| 3 | `lib/core/database/character_repository.dart` | Добавить `resetVoiceProfileToDefault`, `_loadDefaultProfile` | MEDIUM |
| 4 | `lib/features/demo/widgets/voice_settings_panel.dart` | Добавить кнопку Reset и метод `_resetToDefault` | MEDIUM |
| 5 | `test/unit/core/database/character_repository_test.dart` | Unit тесты (новый) | LOW |
| 6 | `test/widget/features/demo/voice_settings_panel_test.dart` | Widget тесты (новый) | LOW |

---

## Критерии приёмки

- [ ] Orson использует мужской голос (Guy/Dmitry/Conrad/Henri/Diego/Ameha/Thiha)
- [ ] Merv использует женский голос (Jenny+Girl/Svetlana/Katja/Denise/Isabella/Mekdes/Nilar)
- [ ] Rate = 0.88-0.90 для медленной понятной речи для детей
- [ ] Style = friendly (или cheerful) где доступно
- [ ] Кнопка Reset работает и возвращает к default настройкам
- [ ] Unit тесты проходят
- [ ] Ручное тестирование пройдено
