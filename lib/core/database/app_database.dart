import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

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
  BoolColumn get waitForAnswer => boolean().withDefault(const Constant(false))();
  BoolColumn get showPreviousAnimals => boolean().withDefault(const Constant(false))();

  // Animals (JSON array)
  TextColumn get animalsJson => text().nullable()(); // [{"type": "butterfly", "emoji": "🦋", "count": 1}]

  // Audio files (JSON maps)
  TextColumn get audioFilesJson => text().nullable()(); // {"en": "/path/to/en.mp3"}
  TextColumn get audioStaleJson => text().nullable()(); // {"en": false, "ru": true}

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

@DriftDatabase(tables: [Lessons, Scenes, AudioCaches])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;

  /// Get singleton instance
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will go here
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
