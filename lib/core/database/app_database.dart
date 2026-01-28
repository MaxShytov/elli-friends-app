import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Characters table - stores character metadata and voice profiles
class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Unique character identifier (e.g., "orson", "elli", "bono")
  TextColumn get characterId => text().unique()();

  /// Localized name as JSON: {"en": "Orson the Lion", "ru": "Орсон Лев"}
  TextColumn get nameJson => text()();

  /// Character emoji for display
  TextColumn get emoji => text()();

  /// Localized description as JSON (optional)
  TextColumn get descriptionJson => text().nullable()();

  /// Voice profiles per language as JSON
  /// Format: {"en": {"voiceName": "en-US-GuyNeural", "role": "...", ...}, "ru": {...}}
  TextColumn get voiceProfilesJson => text()();

  /// Character color for UI (hex format)
  TextColumn get color => text().withDefault(const Constant('#FF9800'))();

  /// Character type hint - is this a child character?
  BoolColumn get isChild => boolean().withDefault(const Constant(false))();

  /// Character type hint - is this a male character?
  BoolColumn get isMale => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Lessons table - stores lesson metadata
class Lessons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get lessonId => text().unique()(); // "counting_friends"
  TextColumn get topic => text()(); // "counting", "subtraction"
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  TextColumn get tags => text()(); // JSON array: ["counting", "numbers"]
  TextColumn get titleJson => text()(); // {"en": "Counting", "ru": "Счёт"}
  TextColumn get descriptionJson => text()(); // {"en": "Learn...", "ru": "..."}
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Scenes table - stores individual scene/chunk data
class Scenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lessonId => integer().references(Lessons, #id)();
  IntColumn get orderIndex => integer()(); // Position in lesson (0, 1, 2, ...)

  // Main character
  TextColumn get character => text().nullable()(); // "orson", "merv", "elli"
  TextColumn get animation => text().nullable()(); // "anim_wave", "anim_happy"
  TextColumn get emotion => text().nullable()(); // "Happy", "Sad", "Eating"

  // Second character (optional)
  TextColumn get secondCharacter => text().nullable()();
  TextColumn get secondAnimation => text().nullable()();
  TextColumn get secondEmotion => text().nullable()();

  // Localized content (JSON strings)
  TextColumn get dialogueJson => text().nullable()(); // {"en": "Hello!", "ru": "Привет!"}
  TextColumn get buttonTitleJson => text().nullable()(); // {"en": "Continue", "ru": "Далее"}

  // Scene parameters
  IntColumn get duration => integer().nullable()();
  TextColumn get tone => text().nullable()(); // "friendly", "excited", "questioning"
  TextColumn get transitionType => text().nullable()(); // "auto_tts", "auto_timer", "button", "task"

  // Question-related fields
  BoolColumn get isQuestion => boolean().withDefault(const Constant(false))();
  BoolColumn get isPause => boolean().withDefault(const Constant(false))();
  IntColumn get correctAnswer => integer().nullable()();
  TextColumn get correctAnswerTextJson => text().nullable()(); // {"en": "white", "ru": "белый"}
  TextColumn get answerOptionsJson => text().nullable()(); // JSON array of answer options
  BoolColumn get waitForAnswer => boolean().withDefault(const Constant(false))();
  BoolColumn get showPreviousAnimals => boolean().withDefault(const Constant(false))();

  // Animals (JSON array)
  TextColumn get animalsJson => text().nullable()(); // [{"type": "butterfly", "emoji": "🦋", "count": 1}]

  // Audio files (JSON maps)
  TextColumn get audioFilesJson => text().nullable()(); // {"en": "/path/to/en.mp3"}
  TextColumn get audioStaleJson => text().nullable()(); // {"en": false, "ru": true}

  // Voice context for this scene's dialogue (DialogueVoiceContext as JSON)
  // Format: {"style": "excited", "styleDegree": 1.3, "pitchModifier": "+5%", ...}
  TextColumn get voiceContextJson => text().nullable()();

  // Background image or gradient key for scene
  TextColumn get backgroundKey => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Audio cache table - stores generated TTS audio file metadata
class AudioCaches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sceneId => integer().references(Scenes, #id)();
  TextColumn get languageCode => text()(); // "en", "ru", "fr"
  TextColumn get character => text()(); // "orson"
  TextColumn get filePath => text()(); // "/cache/audio/scene_1_en.mp3"
  TextColumn get ttsProvider => text()(); // "azure", "google", "openai"
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get textHash => text()(); // MD5 hash for invalidation
}

@DriftDatabase(tables: [Characters, Lessons, Scenes, AudioCaches])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  /// Constructor for testing with custom executor
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  static AppDatabase? _instance;

  /// Get singleton instance
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from v1 to v2: Add Characters table and new Scenes columns
        if (from < 2) {
          // Create Characters table
          await m.createTable(characters);

          // Add new columns to Scenes table
          await m.addColumn(scenes, scenes.voiceContextJson);
          await m.addColumn(scenes, scenes.backgroundKey);
        }
        // Migration from v2 to v3: Add text answer fields
        if (from < 3) {
          await m.addColumn(scenes, scenes.correctAnswerTextJson);
          await m.addColumn(scenes, scenes.answerOptionsJson);
        }
      },
    );
  }

  /// Close database connection
  static Future<void> closeDatabase() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'elli_friends.db'));
    return NativeDatabase.createInBackground(file);
  });
}
