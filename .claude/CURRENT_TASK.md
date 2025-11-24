# Current Task: Chunk-based Scenario Editor with Database & TTS API

## Overview

Задача: Перенести хранение chunks (сцен/чанков) из JSON-файлов в локальную базу данных с возможностью редактирования и генерации аудио через внешние API.

---

## Research

### 1. Текущая архитектура хранения сценариев

**Где хранятся данные сейчас:**
- JSON-файлы: `assets/data/lessons/lesson_counting.json`, `lesson_subtraction.json`
- Загрузка через: [lesson_local_data_source.dart](lib/features/lessons/data/datasources/lesson_local_data_source.dart)
- Парсинг: `rootBundle.loadString()` → `json.decode()` → `LessonModel.fromJson()`

**Структура чанка (Scene) в JSON:**
```json
{
  "character": "orson",
  "dialogue": {
    "en": "Hello, I'm Orson!",
    "ru": "Привет, я Орсон!",
    "fr": "Bonjour, je suis Orson!",
    "it": "Ciao, sono Orson!",
    "de": "Hallo, ich bin Orson!",
    "my": "မင်္ဂလာပါ၊ ကျွန်တော် Orson ပါ!"
  },
  "duration": 2,
  "tone": "friendly",
  "animation": "anim_wave",
  "emotion": "Happy",
  "transitionType": "auto_tts",
  "animals": [{"type": "butterfly", "emoji": "🦋", "count": 1}],
  "isQuestion": false,
  "correctAnswer": null,
  "waitForAnswer": false,
  "secondCharacter": "merv",
  "secondAnimation": "anim_idle",
  "secondEmotion": "Happy",
  "buttonTitle": {"en": "Continue", "ru": "Далее"}
}
```

**Полный список параметров Scene (из [lesson.dart:26-85](lib/features/lessons/domain/entities/lesson.dart#L26-L85)):**
- `character` — персонаж (orson, merv, elli, bono, hippo)
- `dialogue` — текст диалога (локализованный)
- `duration` — длительность в секундах
- `tone` — тон голоса (friendly, excited, questioning, etc.)
- `animation` — Rive анимация (anim_wave, anim_happy, anim_idle, anim_walk_front, anim_sad)
- `emotion` — эмоция персонажа (Happy, Sad, Eating, Intense Sad, Angry, Neutral)
- `transitionType` — тип перехода (auto_tts, auto_timer, button, task)
- `animals` — список животных [{type, emoji, count}]
- `isQuestion` — это вопрос?
- `isPause` — это пауза?
- `correctAnswer` — правильный ответ (число)
- `waitForAnswer` — ждать ответа?
- `showPreviousAnimals` — показывать предыдущих животных?
- `buttonTitle` — текст кнопки (локализованный)
- `secondCharacter` — второй персонаж
- `secondAnimation` — анимация второго персонажа
- `secondEmotion` — эмоция второго персонажа

---

### 2. Выбор БД: Drift (type-safe SQLite)

#### Сравнение вариантов:

| БД | Преимущества | Недостатки | Статус (2025) |
|----|--------------|------------|---------------|
| **Drift (moor)** ✅ | SQL, type-safe, миграции, активно развивается | Сложнее для JSON-структур | ✅ Активно развивается |
| **Isar** | NoSQL, Map поддержка, простой API | ⚠️ **Заброшен** (нет обновлений с 2023) | ❌ Заброшен |
| **Isar Community** | Форк Isar, совместимость | Неизвестно будущее форка | ⚠️ Community-поддержка |
| **Hive** | Легковесная, key-value | Нет сложных запросов | ⚠️ Минимальная поддержка |
| **sqflite** | Стандартный SQLite | Много boilerplate | ✅ Поддерживается |
| **ObjectBox** | Очень быстрая | Меньше сообщества, проприетарная | ✅ Активно развивается |

**Выбор: Drift** (ранее назывался moor)

Почему Drift лучше для этой задачи:
- ✅ **Активно развивается** — регулярные обновления (в отличие от заброшенного Isar)
- ✅ **Type-safe SQLite** — проверка типов и запросов на этапе компиляции
- ✅ Встроенные миграции схемы
- ✅ Поддержка Web, iOS, Android, macOS, Windows, Linux
- ✅ Реактивные Streams для UI обновлений
- ✅ Хорошая документация и большое сообщество
- ✅ Manager API для удобных CRUD операций

**Примечание:** Isar изначально планировался, но был заброшен разработчиком. Drift — надёжный выбор для продакшена.

---

### 3. Схема базы данных (Isar Collections)

```dart
// lib/core/database/collections/lesson_collection.dart

import 'package:isar/isar.dart';

part 'lesson_collection.g.dart';

@collection
class LessonEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String lessonId;  // "counting_friends"

  late String topic;     // "counting", "subtraction"
  late int difficulty;   // 1-5
  late List<String> tags;

  // Локализованные поля как Map
  late Map<String, String> title;       // {"en": "Counting", "ru": "Счёт"}
  late Map<String, String> description; // {"en": "Learn...", "ru": "Учимся..."}

  late DateTime createdAt;
  late DateTime updatedAt;

  // Связь со сценами (backlink)
  final scenes = IsarLinks<SceneEntity>();
}

@collection
class SceneEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int orderIndex;  // Позиция в уроке (0, 1, 2, ...)

  // Основной персонаж
  String? character;    // "orson", "merv", "elli"
  String? animation;    // "anim_wave", "anim_happy"
  String? emotion;      // "Happy", "Sad", "Eating"

  // Второй персонаж (опционально)
  String? secondCharacter;
  String? secondAnimation;
  String? secondEmotion;

  // Локализованный контент
  Map<String, String>? dialogue;    // {"en": "Hello!", "ru": "Привет!"}
  Map<String, String>? buttonTitle; // {"en": "Continue", "ru": "Далее"}

  // Параметры сцены
  int? duration;
  String? tone;           // "friendly", "excited", "questioning"
  String? transitionType; // "auto_tts", "auto_timer", "button", "task"

  // Вопросы
  bool isQuestion = false;
  bool isPause = false;
  int? correctAnswer;
  bool waitForAnswer = false;
  bool showPreviousAnimals = false;

  // Животные (embedded list)
  List<AnimalEmbed> animals = [];

  // Аудио файлы для каждого языка
  Map<String, String>? audioFiles; // {"en": "/path/to/en.mp3", "ru": "/path/to/ru.mp3"}
  Map<String, bool>? audioStale;   // {"en": false, "ru": true} - нужна перегенерация?

  // Связь с уроком
  @Backlink(to: 'scenes')
  final lesson = IsarLink<LessonEntity>();

  DateTime? updatedAt;
}

@embedded
class AnimalEmbed {
  late String type;   // "butterfly", "monkey", "bird"
  late String emoji;  // "🦋", "🐵", "🐦"
  late int count;     // 1, 2, 3...
}

@collection
class AudioCacheEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int sceneId;

  @Index()
  late String languageCode;  // "en", "ru", "fr"

  late String character;     // "orson"
  late String filePath;      // "/cache/audio/scene_1_en.mp3"
  late String ttsProvider;   // "elevenlabs", "google", "openai"

  late DateTime generatedAt;
  late String textHash;      // MD5 хэш текста для инвалидации
}
```

#### Визуальная схема:

```
┌─────────────────────────────────────────────────────────────┐
│                      LessonEntity                            │
├─────────────────────────────────────────────────────────────┤
│  id: 1                                                       │
│  lessonId: "counting_friends"                               │
│  topic: "counting"                                          │
│  difficulty: 1                                              │
│  title: {"en": "Counting as a Game", "ru": "Счёт как игра"} │
│  description: {...}                                         │
│  tags: ["counting", "numbers", "basic"]                     │
│                                                              │
│  scenes ──────┐                                              │
└───────────────┼──────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│                      SceneEntity                             │
├─────────────────────────────────────────────────────────────┤
│  id: 1                                                       │
│  orderIndex: 0                                              │
│  character: "orson"                                         │
│  animation: "anim_wave"                                     │
│  emotion: "Happy"                                           │
│  dialogue: {"en": "Hello!", "ru": "Привет!"}                │
│  transitionType: "auto_tts"                                 │
│  animals: [AnimalEmbed(butterfly, 🦋, 1)]                   │
│  audioFiles: {"en": "/cache/s1_en.mp3", "ru": "/cache/..."}│
│  audioStale: {"en": false, "ru": false}                     │
└─────────────────────────────────────────────────────────────┘
```

---

### 4. API для генерации человеческого голоса (TTS)

#### Поддержка языков Мьянмы (Burmese) и Эфиопии (Amharic):

| API | Burmese (my) | Amharic (am) | Примечание |
|-----|:------------:|:------------:|------------|
| **Microsoft Azure TTS** | ✅ | ✅ | Единственный с обоими языками! |
| **Google Cloud TTS** | ⚠️ Возможно | ⚠️ Возможно | Есть в Android TTS, в Cloud API уточнить |
| **ElevenLabs** | ❌ | ❌ | Только 32 языка для TTS |
| **OpenAI TTS** | ❌ | ❌ | ~57 языков, эти не включены |
| **Amazon Polly** | ❌ | ❌ | Не подтверждено |

#### Сравнение API для PoC:

| API | Качество | Цена | Языки | my/am | Особенности |
|-----|----------|------|-------|:-----:|-------------|
| **Microsoft Azure TTS** | ⭐⭐⭐⭐ | $15/1M символов | 119+ | ✅✅ | **Рекомендуется!** Neural TTS, оба языка |
| **ElevenLabs** | ⭐⭐⭐⭐⭐ | $5/месяц (30k) | 32 | ❌❌ | Лучшее качество, но нет my/am |
| **Google Cloud TTS** | ⭐⭐⭐⭐ | $4/1M символов | 75+ | ⚠️⚠️ | WaveNet, нужно проверить API |
| **OpenAI TTS** | ⭐⭐⭐⭐⭐ | $15/1M символов | 57 | ❌❌ | Очень естественные, нет my/am |
| **Amazon Polly** | ⭐⭐⭐⭐ | $4/1M символов | 60+ | ❌❌ | Neural, нет my/am |

#### Рекомендация для PoC:

**🏆 Microsoft Azure TTS** (РЕКОМЕНДУЕТСЯ)
- ✅ **Единственный API с поддержкой Burmese И Amharic!**
- 119+ языков, 278+ голосов Neural TTS
- Хорошее качество для детского контента
- Free tier: 500,000 символов/месяц
- $15 за 1M символов (Neural)
- Официальный REST API

```dart
// Пример запроса Azure TTS
POST https://{region}.tts.speech.microsoft.com/cognitiveservices/v1
Headers:
  Ocp-Apim-Subscription-Key: {api_key}
  Content-Type: application/ssml+xml

Body:
<speak version='1.0' xml:lang='en-US'>
  <voice name='en-US-JennyNeural'>
    Hello, I'm Orson!
  </voice>
</speak>

// Голоса для языков приложения:
// en-US: en-US-JennyNeural, en-US-GuyNeural (детские: en-US-AnaNeural)
// ru-RU: ru-RU-SvetlanaNeural, ru-RU-DmitryNeural
// fr-FR: fr-FR-DeniseNeural, fr-FR-HenriNeural
// de-DE: de-DE-KatjaNeural, de-DE-ConradNeural
// it-IT: it-IT-ElsaNeural, it-IT-DiegoNeural
// my-MM: my-MM-NilarNeural, my-MM-ThihaNeural ✅
// am-ET: am-ET-MekdesNeural, am-ET-AmehaNeural ✅
```

#### ✅ ВЫБОР: Microsoft Azure TTS

Используем Azure TTS для всех языков — единый провайдер, простая интеграция.

```dart
// lib/core/services/azure_tts_service.dart

class AzureTtsConfig {
  // Голоса для персонажей по языкам
  static const Map<String, Map<String, String>> characterVoices = {
    'orson': {  // Мужской голос - мудрый лев
      'en': 'en-US-GuyNeural',
      'ru': 'ru-RU-DmitryNeural',
      'fr': 'fr-FR-HenriNeural',
      'de': 'de-DE-ConradNeural',
      'it': 'it-IT-DiegoNeural',
      'my': 'my-MM-ThihaNeural',
      'am': 'am-ET-AmehaNeural',
    },
    'merv': {  // Мужской голос - волшебник (чуть выше)
      'en': 'en-US-ChristopherNeural',
      'ru': 'ru-RU-DmitryNeural',
      'fr': 'fr-FR-AlainNeural',
      'de': 'de-DE-KillianNeural',
      'it': 'it-IT-GiuseppeNeural',
      'my': 'my-MM-ThihaNeural',
      'am': 'am-ET-AmehaNeural',
    },
    'elli': {  // Женский голос - слон
      'en': 'en-US-JennyNeural',
      'ru': 'ru-RU-SvetlanaNeural',
      'fr': 'fr-FR-DeniseNeural',
      'de': 'de-DE-KatjaNeural',
      'it': 'it-IT-ElsaNeural',
      'my': 'my-MM-NilarNeural',
      'am': 'am-ET-MekdesNeural',
    },
    'bono': {  // Детский голос - слон-помощник
      'en': 'en-US-AnaNeural',  // Детский голос
      'ru': 'ru-RU-DariyaNeural',
      'fr': 'fr-FR-EloiseNeural',
      'de': 'de-DE-GiselaNeural',
      'it': 'it-IT-PierinaNeural',
      'my': 'my-MM-NilarNeural',
      'am': 'am-ET-MekdesNeural',
    },
  };
}
```

---

### 5. Архитектура для редактирования чанков

```
┌─────────────────────────────────────────────────────────────────┐
│                      EDITOR MODULE                               │
├─────────────────────────────────────────────────────────────────┤
│  EditorBloc                                                      │
│  ├── AddChunk(lessonId, position, chunk)                        │
│  ├── UpdateChunk(chunkId, updates)                              │
│  ├── SplitChunk(chunkId, splitPoints[])                         │
│  ├── DeleteChunk(chunkId)                                       │
│  ├── ReorderChunks(lessonId, newOrder)                          │
│  └── GenerateAudio(chunkId, languages[])                        │
├─────────────────────────────────────────────────────────────────┤
│  TranslationService                                              │
│  ├── translateText(text, fromLang, toLang)                      │
│  ├── translateToAllLanguages(text, fromLang)                    │
│  └── Providers: Google Translate API, DeepL                     │
├─────────────────────────────────────────────────────────────────┤
│  TtsApiService                                                   │
│  ├── generateAudio(text, language, character, emotion)          │
│  ├── getVoiceSettings(character)                                │
│  └── Providers: ElevenLabs, Google Cloud TTS                    │
├─────────────────────────────────────────────────────────────────┤
│  AudioCacheService                                               │
│  ├── getCachedAudio(sceneId, language)                          │
│  ├── saveAudio(sceneId, language, audioBytes)                   │
│  └── clearCache()                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

### 6. Seed данных (Isar)

```dart
// lib/core/database/seed_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'collections/lesson_collection.dart';

class SeedService {
  final Isar isar;

  SeedService(this.isar);

  /// Проверить, нужен ли seed
  Future<bool> needsSeed() async {
    final count = await isar.lessonEntitys.count();
    return count == 0;
  }

  /// Загрузить данные из JSON при первом запуске
  Future<void> seedFromAssets() async {
    if (!await needsSeed()) return;

    final lessonFiles = ['lesson_counting.json', 'lesson_subtraction.json'];

    await isar.writeTxn(() async {
      for (final file in lessonFiles) {
        await _seedLesson('assets/data/lessons/$file');
      }
    });
  }

  Future<void> _seedLesson(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    // Создаём урок
    final lesson = LessonEntity()
      ..lessonId = json['id'] as String
      ..topic = json['topic'] as String
      ..difficulty = json['difficulty'] as int
      ..tags = List<String>.from(json['tags'] ?? [])
      ..title = Map<String, String>.from(json['title'])
      ..description = Map<String, String>.from(json['description'])
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await isar.lessonEntitys.put(lesson);

    // Создаём сцены
    final scenes = json['scenes'] as List;
    for (var i = 0; i < scenes.length; i++) {
      final sceneJson = scenes[i] as Map<String, dynamic>;

      final scene = SceneEntity()
        ..orderIndex = i
        ..character = sceneJson['character'] as String?
        ..animation = sceneJson['animation'] as String?
        ..emotion = sceneJson['emotion'] as String?
        ..secondCharacter = sceneJson['secondCharacter'] as String?
        ..secondAnimation = sceneJson['secondAnimation'] as String?
        ..secondEmotion = sceneJson['secondEmotion'] as String?
        ..dialogue = _extractLocalizedMap(sceneJson['dialogue'])
        ..buttonTitle = _extractLocalizedMap(sceneJson['buttonTitle'])
        ..duration = sceneJson['duration'] as int?
        ..tone = sceneJson['tone'] as String?
        ..transitionType = sceneJson['transitionType'] as String?
        ..isQuestion = sceneJson['isQuestion'] as bool? ?? false
        ..isPause = sceneJson['isPause'] as bool? ?? false
        ..correctAnswer = sceneJson['correctAnswer'] as int?
        ..waitForAnswer = sceneJson['waitForAnswer'] as bool? ?? false
        ..showPreviousAnimals = sceneJson['showPreviousAnimals'] as bool? ?? false
        ..animals = _extractAnimals(sceneJson['animals'])
        ..updatedAt = DateTime.now();

      await isar.sceneEntitys.put(scene);

      // Связываем сцену с уроком
      lesson.scenes.add(scene);
    }

    await lesson.scenes.save();
  }

  Map<String, String>? _extractLocalizedMap(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return Map<String, String>.from(value);
    }
    return null;
  }

  List<AnimalEmbed> _extractAnimals(dynamic value) {
    if (value == null) return [];
    return (value as List).map((a) {
      return AnimalEmbed()
        ..type = a['type'] as String
        ..emoji = a['emoji'] as String
        ..count = a['count'] as int;
    }).toList();
  }

  /// Сбросить и перезаполнить БД (для кнопки в настройках)
  Future<void> resetAndReseed() async {
    await isar.writeTxn(() async {
      await isar.lessonEntitys.clear();
      await isar.sceneEntitys.clear();
      await isar.audioCacheEntitys.clear();
    });
    await seedFromAssets();
  }
}
```

---

### 7. Workflow редактирования чанка

```
┌─────────────────────────────────────────────────────────────────┐
│  EDIT CHUNK FLOW                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User edits dialogue text in primary language (e.g., EN)     │
│     ↓                                                            │
│  2. TranslationService.translateToAllLanguages()                │
│     ↓                                                            │
│  3. DB: Update all LocalizedTexts for this scene                │
│     ↓                                                            │
│  4. Mark existing audio as "stale" (needs_regeneration = true)  │
│     ↓                                                            │
│  5. Background job: TtsApiService.generateAudio() for each lang │
│     ↓                                                            │
│  6. Save audio files to local storage + update AudioFiles table │
│     ↓                                                            │
│  7. UI shows green checkmark when all audio ready               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### 8. Зависимости для добавления

```yaml
dependencies:
  # База данных Isar
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1  # Нативные библиотеки

  # HTTP для TTS API
  dio: ^5.4.0

  # Кэширование аудио
  path_provider: ^2.1.2
  crypto: ^3.0.3  # Для MD5 хэша текста

  # Перевод (опционально)
  # translator: ^1.0.0

dev_dependencies:
  # Генерация кода Isar
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.8
```

#### Инициализация Isar

```dart
// lib/core/database/database.dart

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/lesson_collection.dart';

class AppDatabase {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [LessonEntitySchema, SceneEntitySchema, AudioCacheEntitySchema],
      directory: dir.path,
      name: 'elli_friends',
    );

    return _instance!;
  }
}
```

#### Интеграция в main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация БД
  final isar = await AppDatabase.getInstance();

  // Seed данных при первом запуске
  final seedService = SeedService(isar);
  await seedService.seedFromAssets();

  runApp(MyApp(isar: isar));
}
```

---

### 9. Решения

| Вопрос | Решение |
|--------|---------|
| **База данных** | Drift (type-safe SQLite) — ранее назывался moor |
| **TTS API** | Microsoft Azure TTS |
| **Перевод текста** | Claude API (автоматический перевод на все языки) |
| **Генерация аудио** | При синхронизации с бэкендом (не в реальном времени) |
| **UI редактора** | Встроенный в приложение (секретный жест triple tap) |
| **Azure ключ** | Отдельная задача: получение и интеграция |

#### Workflow перевода через Claude API:

```dart
// lib/core/services/translation_service.dart

class ClaudeTranslationService {
  final String apiKey;
  final Dio _dio;

  static const languages = ['en', 'ru', 'fr', 'de', 'it', 'my', 'am'];

  /// Перевести текст на все языки приложения
  Future<Map<String, String>> translateToAllLanguages({
    required String text,
    required String sourceLanguage,
  }) async {
    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      }),
      data: {
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 1024,
        'messages': [{
          'role': 'user',
          'content': '''Translate this text for a children's educational app.
Source language: $sourceLanguage
Text: "$text"

Translate to these languages and return ONLY valid JSON:
{
  "en": "English translation",
  "ru": "Russian translation",
  "fr": "French translation",
  "de": "German translation",
  "it": "Italian translation",
  "my": "Burmese translation",
  "am": "Amharic translation"
}

Keep the tone child-friendly and simple.'''
        }]
      },
    );

    // Parse JSON response
    final content = response.data['content'][0]['text'];
    return Map<String, String>.from(jsonDecode(content));
  }
}
```

#### Workflow генерации аудио (при синхронизации):

```
┌─────────────────────────────────────────────────────────────────┐
│  AUDIO GENERATION FLOW (Backend Sync)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Редактор изменяет текст чанка                               │
│     ↓                                                            │
│  2. Claude API переводит на все 7 языков                        │
│     ↓                                                            │
│  3. Сохраняем в локальную БД (Isar)                             │
│     audioStale: {"en": true, "ru": true, ...}                   │
│     ↓                                                            │
│  4. При синхронизации с бэкендом:                               │
│     - Отправляем изменённые чанки на сервер                     │
│     - Сервер генерирует аудио через Azure TTS                   │
│     - Сервер возвращает URLs аудио файлов                       │
│     ↓                                                            │
│  5. Приложение скачивает аудио в локальный кэш                  │
│     audioStale: {"en": false, "ru": false, ...}                 │
│     ↓                                                            │
│  6. Fallback: если нет аудио → системный TTS                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Next Steps

### Phase 1: Database Setup (Drift) ✅ COMPLETED
- [x] Добавить Drift зависимости в pubspec.yaml (drift ^2.22.1, sqlite3_flutter_libs)
- [x] Создать Drift таблицы (Lessons, Scenes, AudioCaches)
- [x] Запустить `flutter pub run build_runner build`
- [x] Создать AppDatabase singleton
- [x] Реализовать SeedService (миграция из JSON)
- [x] Интегрировать в main.dart

**Примечание:** Изначально планировался Isar, но он заброшен. Drift — активно развиваемая type-safe SQLite библиотека.

### Phase 2: Data Layer Migration ✅ COMPLETED
- [x] Создать LessonDriftDataSource (замена LessonLocalDataSource)
- [x] Обновить LessonRepositoryImpl для работы с Drift
- [x] Добавить кнопку "Reset Data" в Settings
- [x] Тестирование: уроки работают из БД

### Phase 3: Editor UI (Secret Gesture Activation) ✅ COMPLETED
- [x] Создать EditorBloc с CRUD операциями для чанков
- [x] UI: список чанков урока с drag-and-drop
- [x] UI: редактирование чанка (персонаж, эмоция, анимация)
- [x] UI: редактирование текста (основной язык)
- [x] Split chunk функциональность
- [x] Интеграция Claude API для автоперевода
- [x] Активация редактора по triple tap (секретный жест на Settings)
- [x] Добавлен ApiKeyService для хранения Claude API ключа
- [x] UI для ввода/редактирования Claude API ключа в Settings
- [x] Исправлен баг: текст диалога очищался при ошибке перевода (EditorError state handling)
- [x] Исправлен баг: сохранённые переводы не загружались при воспроизведении урока (Localization persistence)
- [x] Исправлен баг: несоответствие ID урока (counting vs counting_friends)

**Созданные файлы:**
- `lib/core/services/api_key_service.dart` — сервис хранения API ключей
- `lib/core/services/translation_service.dart` — Claude API интеграция для перевода
- `lib/core/widgets/secret_tap_detector.dart` — виджет секретного жеста
- `lib/features/editor/presentation/bloc/editor_bloc.dart` — BLoC редактора
- `lib/features/editor/presentation/bloc/editor_event.dart` — события
- `lib/features/editor/presentation/bloc/editor_state.dart` — состояния и EditableScene
- `lib/features/editor/presentation/pages/editor_page.dart` — список уроков
- `lib/features/editor/presentation/pages/lesson_editor_page.dart` — редактор урока
- `lib/features/editor/presentation/widgets/scene_list_widget.dart` — drag-drop список
- `lib/features/editor/presentation/widgets/scene_editor_dialog.dart` — диалог редактирования
- `lib/features/editor/presentation/widgets/character_picker.dart` — выбор персонажа
- `lib/features/editor/presentation/widgets/dialogue_editor.dart` — редактор диалогов

**Примечание:** Секретный жест временно отключён, редактор доступен напрямую в Settings для тестирования.

### Phase 4: Azure TTS Integration ✅ COMPLETED
- [x] Создать AzureTtsService с конфигурацией голосов
- [x] Реализовать AudioCacheService (скачивание и кэширование MP3)
- [x] Обновить AudioManager для воспроизведения кэшированного аудио
- [x] Fallback на системный TTS если нет аудио
- [x] Добавить UI для ввода Azure API key в Settings
- [x] Расширить ApiKeyService для хранения Azure key и region

**Созданные файлы:**
- `lib/core/services/azure_tts_service.dart` — Azure TTS API интеграция с голосами персонажей
- `lib/core/services/audio_cache_service.dart` — кэширование аудио файлов

**Изменённые файлы:**
- `lib/core/services/audio_manager.dart` — добавлена поддержка кэшированного аудио
- `lib/core/services/api_key_service.dart` — добавлены методы для Azure key/region
- `lib/features/settings/presentation/pages/settings_page.dart` — добавлен диалог Azure TTS Key
- `lib/features/settings/presentation/pages/tts_test_page.dart` — страница тестирования Azure TTS
- `pubspec.yaml` — добавлена зависимость crypto

**Функционал тестовой страницы (TTS Test Page):**
- Две вкладки: Azure TTS и System TTS
- Выбор персонажа (orson, merv, elli, bono, hippo) с эмодзи
- Выбор языка из 7 поддерживаемых (EN, RU, FR, DE, IT, MY, AM)
- Предпросмотр тестовой фразы для выбранного языка
- Отображение конфигурации голоса (voice name и locale)
- Кнопка "Generate" — генерирует MP3 файл через Azure TTS API
- Кнопка "Play/Stop" — воспроизводит сгенерированный файл (активна только при наличии файла)
- Кэширование: файлы сохраняются по ключу `персонаж_язык`, позволяя переключаться между разными комбинациями без потери ранее сгенерированных файлов
- Информационная карточка с размером файла и кнопкой очистки
- Обработка ошибок с отображением в SnackBar

---

## Инструкция: Создание Azure Speech API Key

### Шаг 1: Создание Azure Account

1. Перейдите на [portal.azure.com](https://portal.azure.com)
2. Если нет аккаунта — зарегистрируйтесь (бесплатный tier доступен)
3. Войдите в Azure Portal

### Шаг 2: Создание Speech Service Resource

1. В поиске Azure Portal введите **"Speech"**
2. Выберите **"Speech services"** (или "Службы речи")
3. Нажмите **"+ Create"** (Создать)
4. Заполните форму:
   - **Subscription**: Выберите вашу подписку
   - **Resource group**: Создайте новую или выберите существующую
   - **Region**: Выберите ближайший регион (например, `eastus`, `westeurope`)
   - **Name**: Уникальное имя (например, `elli-friends-tts`)
   - **Pricing tier**:
     - **Free (F0)** — 500,000 символов/месяц бесплатно (для разработки)
     - **Standard (S0)** — $15 за 1M символов (для продакшена)
5. Нажмите **"Review + create"**, затем **"Create"**
6. Дождитесь создания ресурса (1-2 минуты)

### Шаг 3: Получение API Key

1. После создания нажмите **"Go to resource"**
2. В левом меню выберите **"Keys and Endpoint"** (Ключи и конечная точка)
3. Скопируйте **KEY 1** или **KEY 2** — это ваш `Subscription Key`
4. Запомните **Location/Region** — это ваш `region` (например, `eastus`)

### Шаг 4: Настройка в приложении

1. Откройте приложение Elli & Friends
2. Перейдите в **Settings** → **Lesson Editor** → **Azure TTS Key**
3. Вставьте скопированный ключ в поле **"Subscription Key"**
4. Выберите ваш **Region** из выпадающего списка
5. Нажмите **"Test"** для проверки соединения
6. Если тест успешен, нажмите **"Save"**

### Важные примечания

- **Free tier (F0)**: 500,000 символов/месяц — достаточно для разработки и тестирования
- **Ключи можно перегенерировать** в Azure Portal если они скомпрометированы
- **Не публикуйте ключи** в публичные репозитории
- Голоса для Burmese (my-MM) и Amharic (am-ET) поддерживаются только Azure TTS

### Поддерживаемые голоса в приложении

| Персонаж | EN | RU | FR | DE | IT | MY | AM |
|----------|----|----|----|----|----|----|-----|
| Orson | GuyNeural | DmitryNeural | HenriNeural | ConradNeural | DiegoNeural | ThihaNeural | AmehaNeural |
| Merv | ChristopherNeural | DmitryNeural | AlainNeural | KillianNeural | GiuseppeNeural | ThihaNeural | AmehaNeural |
| Elli | JennyNeural | SvetlanaNeural | DeniseNeural | KatjaNeural | ElsaNeural | NilarNeural | MekdesNeural |
| Bono | AnaNeural | DariyaNeural | EloiseNeural | GiselaNeural | PierinaNeural | NilarNeural | MekdesNeural |
| Hippo | AriaNeural | SvetlanaNeural | DeniseNeural | KatjaNeural | IsabellaNeural | NilarNeural | MekdesNeural |

---

### Phase 5: Backend Sync (будущее)
- [ ] API для синхронизации уроков
- [ ] Отправка изменённых чанков на сервер
- [ ] Получение сгенерированного аудио
- [ ] Версионирование данных

---

## Plan

### Обзор плана

План разделён на 4 фазы:
1. **Phase 1:** Database Setup (Drift) — фундамент ✅ COMPLETED
2. **Phase 2:** Data Layer Migration — переход на Drift
3. **Phase 3:** Editor UI — интерфейс редактора
4. **Phase 4:** TTS Integration — генерация аудио

---

### Phase 1: Database Setup (Drift) ✅ COMPLETED

#### 1.1 Добавить зависимости Isar

**Файл:** `pubspec.yaml`

**Изменения:**
```yaml
dependencies:
  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2
  crypto: ^3.0.3

dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.8
```

**Проверка:** `flutter pub get` успешно завершается

**Тест:** Нет (конфигурация)

---

#### 1.2 Создать Isar Collections

**Новые файлы:**

| Файл | Описание |
|------|----------|
| `lib/core/database/collections/lesson_collection.dart` | LessonEntity, SceneEntity, AnimalEmbed |
| `lib/core/database/collections/audio_cache_collection.dart` | AudioCacheEntity |

**Содержимое `lesson_collection.dart`:**
```dart
import 'package:isar/isar.dart';
part 'lesson_collection.g.dart';

@collection
class LessonEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String lessonId;
  late String topic;
  late int difficulty;
  late List<String> tags;
  late Map<String, String> title;
  late Map<String, String> description;
  late DateTime createdAt;
  late DateTime updatedAt;

  final scenes = IsarLinks<SceneEntity>();
}

@collection
class SceneEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int orderIndex;

  String? character;
  String? animation;
  String? emotion;
  String? secondCharacter;
  String? secondAnimation;
  String? secondEmotion;

  Map<String, String>? dialogue;
  Map<String, String>? buttonTitle;

  int? duration;
  String? tone;
  String? transitionType;

  bool isQuestion = false;
  bool isPause = false;
  int? correctAnswer;
  bool waitForAnswer = false;
  bool showPreviousAnimals = false;

  List<AnimalEmbed> animals = [];

  Map<String, String>? audioFiles;
  Map<String, bool>? audioStale;

  @Backlink(to: 'scenes')
  final lesson = IsarLink<LessonEntity>();

  DateTime? updatedAt;
}

@embedded
class AnimalEmbed {
  String? type;
  String? emoji;
  int? count;
}
```

**Проверка:**
1. `flutter pub run build_runner build` генерирует `*.g.dart` файлы
2. Нет ошибок компиляции

**Тесты:**
- `test/unit/core/database/lesson_collection_test.dart` — создание и чтение entities

---

#### 1.3 Создать AppDatabase singleton

**Новый файл:** `lib/core/database/app_database.dart`

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/lesson_collection.dart';
import 'collections/audio_cache_collection.dart';

class AppDatabase {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [LessonEntitySchema, SceneEntitySchema, AudioCacheEntitySchema],
      directory: dir.path,
      name: 'elli_friends',
    );

    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
```

**Проверка:** Приложение запускается без ошибок

**Тесты:**
- `test/unit/core/database/app_database_test.dart` — открытие/закрытие БД

---

#### 1.4 Реализовать SeedService

**Новый файл:** `lib/core/database/seed_service.dart`

**Функционал:**
- `needsSeed()` — проверка, нужен ли seed
- `seedFromAssets()` — загрузка JSON → Isar при первом запуске
- `resetAndReseed()` — сброс и перезаполнение БД

**Проверка:**
1. Первый запуск — данные загружаются из JSON
2. Повторный запуск — seed не выполняется
3. Кнопка Reset в Settings — данные перезаполняются

**Тесты:**
- `test/unit/core/database/seed_service_test.dart`
  - `seedFromAssets()` создаёт правильное количество lessons и scenes
  - `needsSeed()` возвращает false после seed
  - `resetAndReseed()` очищает и перезаполняет БД

---

#### 1.5 Интегрировать в main.dart

**Файл:** `lib/main.dart`

**Изменения:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация БД
  final isar = await AppDatabase.getInstance();

  // Seed данных при первом запуске
  final seedService = SeedService(isar);
  await seedService.seedFromAssets();

  runApp(MyApp(isar: isar));
}
```

**Проверка:**
1. `flutter run` — приложение запускается
2. Логи показывают успешную инициализацию БД

**Тесты:** Интеграционный тест (Phase 5)

---

### Phase 2: Data Layer Migration

#### 2.1 Создать LessonIsarDataSource

**Новый файл:** `lib/features/lessons/data/datasources/lesson_isar_data_source.dart`

**Методы:**
```dart
abstract class LessonIsarDataSource {
  Future<List<LessonModel>> getAllLessons();
  Future<LessonModel?> getLessonById(String lessonId);
  Future<void> saveLesson(LessonModel lesson);
  Future<void> updateScene(int sceneId, SceneModel scene);
  Future<void> deleteScene(int sceneId);
  Future<void> reorderScenes(String lessonId, List<int> newOrder);
  Stream<List<LessonModel>> watchAllLessons();
}

class LessonIsarDataSourceImpl implements LessonIsarDataSource {
  final Isar isar;

  LessonIsarDataSourceImpl(this.isar);

  // Реализация методов...
}
```

**Проверка:**
1. `getAllLessons()` возвращает уроки из БД
2. `getLessonById()` возвращает конкретный урок
3. Уроки корректно отображаются на HomeScreen

**Тесты:**
- `test/unit/features/lessons/data/datasources/lesson_isar_data_source_test.dart`
  - `getAllLessons()` возвращает все уроки
  - `getLessonById()` возвращает урок по ID
  - `updateScene()` обновляет сцену
  - `reorderScenes()` меняет порядок

---

#### 2.2 Обновить LessonRepositoryImpl

**Файл:** `lib/features/lessons/data/repositories/lesson_repository_impl.dart`

**Изменения:**
```dart
class LessonRepositoryImpl implements LessonRepository {
  final LessonIsarDataSource isarDataSource;
  final LessonLocalDataSource localDataSource; // Fallback

  LessonRepositoryImpl({
    required this.isarDataSource,
    this.localDataSource,
  });

  @override
  Future<List<Lesson>> getAllLessons() async {
    try {
      final models = await isarDataSource.getAllLessons();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Fallback to JSON if DB fails
      if (localDataSource != null) {
        return localDataSource!.getAllLessons();
      }
      rethrow;
    }
  }
}
```

**Проверка:**
1. `flutter run` — уроки загружаются из Isar
2. HomeScreen отображает список уроков
3. LessonPage воспроизводит урок

**Тесты:**
- Обновить `test/unit/features/lessons/data/repositories/lesson_repository_impl_test.dart`
  - Мок `LessonIsarDataSource`
  - Проверка fallback на `LessonLocalDataSource`

---

#### 2.3 Добавить кнопку "Reset Data" в Settings

**Файл:** `lib/features/settings/presentation/pages/settings_page.dart`

**Изменения:**
- Добавить кнопку "Reset Lesson Data" (только в debug mode)
- По нажатию: `await seedService.resetAndReseed()`
- Показать SnackBar с подтверждением

**Проверка:**
1. Кнопка видна только в debug mode
2. После нажатия — данные сбрасываются
3. Уроки работают после сброса

**Тесты:**
- `test/widget/features/settings/settings_page_test.dart`
  - Кнопка Reset видна в debug mode
  - Кнопка Reset скрыта в release mode

---

### Phase 3: Editor UI (Secret Gesture Activation)

#### 3.0 Реализовать секретный жест для активации редактора

**Механизм активации:**
- Triple tap на заголовке "Settings" или версии приложения
- После активации показывается секция "Developer Tools" с кнопкой "Lesson Editor"
- Состояние сохраняется в SharedPreferences (опционально — сбрасывается при перезапуске)

**Новый файл:** `lib/core/widgets/secret_tap_detector.dart`

```dart
import 'package:flutter/material.dart';

class SecretTapDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onSecretTap;
  final int requiredTaps; // default: 3

  const SecretTapDetector({
    super.key,
    required this.child,
    required this.onSecretTap,
    this.requiredTaps = 3,
  });

  @override
  State<SecretTapDetector> createState() => _SecretTapDetectorState();
}

class _SecretTapDetectorState extends State<SecretTapDetector> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();

    // Reset if more than 500ms between taps
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds > 500) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTap = now;

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      widget.onSecretTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
```

**Интеграция в Settings:**

```dart
// settings_page.dart
class _SettingsPageState extends State<SettingsPage> {
  bool _editorUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SecretTapDetector(
          onSecretTap: () {
            setState(() => _editorUnlocked = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🔓 Editor mode unlocked!')),
            );
          },
          child: const Text('Settings'),
        ),
      ),
      body: ListView(
        children: [
          // ... normal settings ...

          if (_editorUnlocked) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Lesson Editor'),
              subtitle: const Text('Edit lesson scenarios'),
              onTap: () => context.push('/editor'),
            ),
          ],
        ],
      ),
    );
  }
}
```

**Проверка:**
1. Triple tap на "Settings" показывает "Editor mode unlocked!"
2. Появляется секция с кнопкой "Lesson Editor"
3. Работает в release build (TestFlight)

**Тесты:**
- `test/unit/core/widgets/secret_tap_detector_test.dart`
  - 3 быстрых тапа активируют callback
  - Медленные тапы (>500ms) сбрасывают счётчик
  - 2 тапа не активируют callback

---

#### 3.1 Создать EditorBloc

**Новые файлы:**
| Файл | Описание |
|------|----------|
| `lib/features/editor/presentation/bloc/editor_bloc.dart` | BLoC для редактора |
| `lib/features/editor/presentation/bloc/editor_event.dart` | События редактора |
| `lib/features/editor/presentation/bloc/editor_state.dart` | Состояния редактора |

**События:**
```dart
abstract class EditorEvent extends Equatable {}

class LoadLessonForEditing extends EditorEvent {
  final String lessonId;
}

class UpdateSceneDialogue extends EditorEvent {
  final int sceneId;
  final String languageCode;
  final String newText;
}

class UpdateSceneCharacter extends EditorEvent {
  final int sceneId;
  final String character;
  final String animation;
  final String emotion;
}

class AddScene extends EditorEvent {
  final String lessonId;
  final int position;
}

class DeleteScene extends EditorEvent {
  final int sceneId;
}

class ReorderScenes extends EditorEvent {
  final List<int> newOrder;
}

class TranslateSceneDialogue extends EditorEvent {
  final int sceneId;
  final String sourceLanguage;
}

class GenerateSceneAudio extends EditorEvent {
  final int sceneId;
  final List<String> languages;
}
```

**Проверка:**
1. События корректно обрабатываются
2. Состояние обновляется после каждого события

**Тесты:**
- `test/unit/features/editor/presentation/bloc/editor_bloc_test.dart`
  - `LoadLessonForEditing` загружает урок
  - `UpdateSceneDialogue` обновляет текст
  - `AddScene` добавляет сцену
  - `DeleteScene` удаляет сцену
  - `ReorderScenes` меняет порядок

---

#### 3.2 Создать EditorPage

**Новые файлы:**
| Файл | Описание |
|------|----------|
| `lib/features/editor/presentation/pages/editor_page.dart` | Главная страница редактора |
| `lib/features/editor/presentation/widgets/scene_list_widget.dart` | Список сцен (drag-and-drop) |
| `lib/features/editor/presentation/widgets/scene_editor_widget.dart` | Редактор одной сцены |
| `lib/features/editor/presentation/widgets/character_picker.dart` | Выбор персонажа |
| `lib/features/editor/presentation/widgets/dialogue_editor.dart` | Редактор текста |

**UI:**
```
┌─────────────────────────────────────────────────┐
│  Editor: Lesson "Counting as a Game"            │
├─────────────────────────────────────────────────┤
│  [Scene List - Drag & Drop]                     │
│  ┌─────────────────────────────────────────┐    │
│  │ 1. Orson: "Hello, I'm Orson!" 🔊 ✅    │    │
│  │    [Edit] [Delete]                       │    │
│  ├─────────────────────────────────────────┤    │
│  │ 2. Orson: "Let's count!" 🔊 ⚠️ (stale) │    │
│  │    [Edit] [Delete]                       │    │
│  ├─────────────────────────────────────────┤    │
│  │ [+ Add Scene]                            │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

**Проверка:**
1. Список сцен отображается
2. Drag-and-drop работает
3. Редактирование сцены открывает диалог

**Тесты:**
- `test/widget/features/editor/editor_page_test.dart`
  - Список сцен отображается
  - Добавление новой сцены
  - Удаление сцены

---

#### 3.3 Добавить роут в GoRouter

**Файл:** `lib/core/router/app_router.dart`

**Изменения:**
```dart
GoRoute(
  path: '/editor/:lessonId',
  builder: (context, state) => EditorPage(
    lessonId: state.pathParameters['lessonId']!,
  ),
),
```

**Проверка:** Переход на `/editor/counting_friends` открывает редактор

**Тесты:** Нет (конфигурация)

---

#### 3.4 Интегрировать Claude API для автоперевода

**Новый файл:** `lib/core/services/translation_service.dart`

**Методы:**
```dart
abstract class TranslationService {
  Future<Map<String, String>> translateToAllLanguages({
    required String text,
    required String sourceLanguage,
  });
}

class ClaudeTranslationService implements TranslationService {
  final Dio dio;
  final String apiKey;

  static const languages = ['en', 'ru', 'fr', 'de', 'it', 'my', 'am'];

  @override
  Future<Map<String, String>> translateToAllLanguages({...}) async {
    // Claude API call
  }
}
```

**Проверка:**
1. Перевод текста на все языки работает
2. UI показывает прогресс перевода

**Тесты:**
- `test/unit/core/services/translation_service_test.dart`
  - Мок Dio для тестирования без реальных API вызовов
  - Проверка парсинга JSON ответа

---

### Phase 4: Azure TTS Integration

#### 4.1 Создать AzureTtsService

**Новый файл:** `lib/core/services/azure_tts_service.dart`

**Методы:**
```dart
abstract class TtsApiService {
  Future<Uint8List> generateAudio({
    required String text,
    required String language,
    required String character,
    String? emotion,
  });
}

class AzureTtsService implements TtsApiService {
  final Dio dio;
  final String subscriptionKey;
  final String region;

  static const characterVoices = {
    'orson': {'en': 'en-US-GuyNeural', 'ru': 'ru-RU-DmitryNeural', ...},
    'elli': {'en': 'en-US-JennyNeural', 'ru': 'ru-RU-SvetlanaNeural', ...},
    // ...
  };

  @override
  Future<Uint8List> generateAudio({...}) async {
    // Azure TTS API call
  }
}
```

**Проверка:**
1. Генерация аудио для одного текста работает
2. Аудио сохраняется в файл

**Тесты:**
- `test/unit/core/services/azure_tts_service_test.dart`
  - Мок Dio
  - Проверка SSML генерации
  - Проверка выбора голоса по персонажу

---

#### 4.2 Создать AudioCacheService

**Новый файл:** `lib/core/services/audio_cache_service.dart`

**Методы:**
```dart
abstract class AudioCacheService {
  Future<String?> getCachedAudioPath(int sceneId, String language);
  Future<void> saveAudio(int sceneId, String language, Uint8List audioData);
  Future<void> markAsStale(int sceneId, String language);
  Future<bool> isStale(int sceneId, String language);
  Future<void> clearCache();
}

class AudioCacheServiceImpl implements AudioCacheService {
  final Isar isar;
  final String cacheDirectory;

  // Реализация...
}
```

**Проверка:**
1. Аудио сохраняется в кэш
2. Аудио загружается из кэша
3. Stale флаг корректно работает

**Тесты:**
- `test/unit/core/services/audio_cache_service_test.dart`
  - Сохранение и загрузка аудио
  - Проверка stale флага
  - Очистка кэша

---

#### 4.3 Обновить AudioManager

**Файл:** `lib/core/services/audio_manager.dart`

**Изменения:**
```dart
class AudioManager {
  final AudioCacheService? audioCacheService;

  Future<void> speak(
    String text, {
    required String character,
    String? language,
  }) async {
    // 1. Попробовать загрузить кэшированное аудио
    final cachedPath = await audioCacheService?.getCachedAudioPath(
      sceneId, language,
    );

    if (cachedPath != null) {
      await _playFile(cachedPath);
      return;
    }

    // 2. Fallback на системный TTS
    await _speakWithSystemTts(text, language: language);
  }
}
```

**Проверка:**
1. Кэшированное аудио воспроизводится
2. Fallback на TTS работает если нет кэша

**Тесты:**
- Обновить `test/unit/core/services/audio_manager_test.dart`
  - Проверка приоритета кэша над TTS
  - Проверка fallback

---

### Порядок выполнения

```
Phase 1: Database Setup
├── 1.1 pubspec.yaml зависимости
├── 1.2 Isar Collections
├── 1.3 AppDatabase singleton
├── 1.4 SeedService
└── 1.5 main.dart интеграция

Phase 2: Data Layer Migration
├── 2.1 LessonIsarDataSource
├── 2.2 LessonRepositoryImpl обновление
└── 2.3 Settings "Reset Data"

Phase 3: Editor UI
├── 3.1 EditorBloc
├── 3.2 EditorPage + widgets
├── 3.3 GoRouter роут
└── 3.4 TranslationService (Claude API)

Phase 4: TTS Integration
├── 4.1 AzureTtsService
├── 4.2 AudioCacheService
└── 4.3 AudioManager обновление
```

---

### Сводная таблица тестов

| Файл теста | Тестируемый компонент | Тип |
|------------|----------------------|-----|
| `test/unit/core/database/lesson_collection_test.dart` | LessonEntity, SceneEntity | Unit |
| `test/unit/core/database/app_database_test.dart` | AppDatabase | Unit |
| `test/unit/core/database/seed_service_test.dart` | SeedService | Unit |
| `test/unit/features/lessons/data/datasources/lesson_isar_data_source_test.dart` | LessonIsarDataSource | Unit |
| `test/unit/features/lessons/data/repositories/lesson_repository_impl_test.dart` | LessonRepositoryImpl | Unit |
| `test/unit/features/editor/presentation/bloc/editor_bloc_test.dart` | EditorBloc | Unit |
| `test/unit/core/services/translation_service_test.dart` | ClaudeTranslationService | Unit |
| `test/unit/core/services/azure_tts_service_test.dart` | AzureTtsService | Unit |
| `test/unit/core/services/audio_cache_service_test.dart` | AudioCacheService | Unit |
| `test/widget/features/editor/editor_page_test.dart` | EditorPage | Widget |
| `test/widget/features/settings/settings_page_test.dart` | SettingsPage Reset | Widget |

---

### Критерии готовности (Definition of Done)

#### Phase 1 завершена когда:
- [ ] `flutter pub get` успешно
- [ ] `flutter pub run build_runner build` генерирует `.g.dart`
- [ ] Приложение запускается и инициализирует БД
- [ ] Seed загружает данные из JSON в Isar
- [ ] Все тесты Phase 1 проходят

#### Phase 2 завершена когда:
- [ ] Уроки загружаются из Isar (не из JSON)
- [ ] HomeScreen отображает уроки из БД
- [ ] LessonPage воспроизводит урок из БД
- [ ] Кнопка Reset в Settings сбрасывает данные
- [ ] Все тесты Phase 2 проходят

#### Phase 3 завершена когда:
- [ ] Triple tap на "Settings" разблокирует редактор
- [ ] Редактор открывается по маршруту `/editor/:lessonId`
- [ ] Список сцен отображается с drag-and-drop
- [ ] Редактирование сцены сохраняется в БД
- [ ] Автоперевод через Claude API работает
- [ ] Работает в release build (TestFlight)
- [ ] Все тесты Phase 3 проходят

#### Phase 4 завершена когда:
- [ ] Azure TTS генерирует аудио
- [ ] Аудио кэшируется локально
- [ ] AudioManager использует кэш → fallback на TTS
- [ ] Stale флаг помечает устаревшее аудио
- [ ] Все тесты Phase 4 проходят

---

## References

- [Isar Documentation](https://isar.dev/)
- [Isar GitHub](https://github.com/isar/isar)
- [Azure Speech Service](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/)
- [Azure TTS REST API](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-text-to-speech)
- [Azure Neural Voices](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=tts)
