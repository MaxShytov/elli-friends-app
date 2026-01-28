import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_database.dart';

/// Service for seeding the database with initial data from JSON assets
class SeedService {
  final AppDatabase db;

  SeedService(this.db);

  /// List of lesson JSON files to seed
  static const List<String> _lessonFiles = [
    'assets/data/lessons/lesson_counting.json',
    'assets/data/lessons/lesson_subtraction.json',
    'assets/data/lessons/lesson_adding_fruits.json',
    'assets/data/lessons/lesson_colors_in_the_jungle_p1.json',
    'assets/data/lessons/lesson_colors_in_the_jungle_p2.json',
    'assets/data/lessons/lesson_shapes_in_the_jungle.json',
    'assets/data/lessons/lesson_english_greetings.json',
  ];

  /// Characters JSON file path
  static const String _charactersFile = 'assets/data/characters.json';

  /// Check if lessons need seeding (empty database)
  Future<bool> needsLessonsSeed() async {
    final count = await db.managers.lessons.count();
    return count == 0;
  }

  /// Check if characters need seeding
  Future<bool> needsCharactersSeed() async {
    final count = await db.managers.characters.count();
    return count == 0;
  }

  /// Seed database from JSON assets on first launch
  Future<void> seedFromAssets() async {
    // Seed characters first (they don't depend on lessons)
    if (await needsCharactersSeed()) {
      debugPrint('SeedService: Seeding characters...');
      await _seedCharacters();
    }

    // Then seed lessons
    if (await needsLessonsSeed()) {
      debugPrint('SeedService: Seeding lessons from JSON assets...');
      for (final file in _lessonFiles) {
        await _seedLesson(file);
      }
    } else {
      debugPrint('SeedService: Lessons already seeded, skipping');
    }

    final lessonCount = await db.managers.lessons.count();
    final sceneCount = await db.managers.scenes.count();
    final characterCount = await db.managers.characters.count();
    debugPrint(
      'SeedService: Seed complete. Lessons: $lessonCount, Scenes: $sceneCount, Characters: $characterCount',
    );
  }

  /// Seed characters with voice profiles from JSON asset
  Future<void> _seedCharacters() async {
    try {
      final jsonString = await rootBundle.loadString(_charactersFile);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final charactersList = json['characters'] as List;

      for (final charJson in charactersList) {
        final charMap = charJson as Map<String, dynamic>;

        // Convert voiceProfiles to proper format with pitch as string
        final voiceProfiles = charMap['voiceProfiles'] as Map<String, dynamic>;
        final convertedProfiles = <String, dynamic>{};

        for (final entry in voiceProfiles.entries) {
          final profile = Map<String, dynamic>.from(entry.value as Map);
          // Convert basePitch from int to string format if needed
          if (profile['basePitch'] is int) {
            final pitch = profile['basePitch'] as int;
            profile['basePitch'] = pitch >= 0 ? '+$pitch%' : '$pitch%';
          }
          convertedProfiles[entry.key] = profile;
        }

        await db.into(db.characters).insertOnConflictUpdate(
          CharactersCompanion.insert(
            characterId: charMap['characterId'] as String,
            nameJson: jsonEncode(charMap['name']),
            emoji: charMap['emoji'] as String,
            descriptionJson: Value(
              charMap['description'] != null
                  ? jsonEncode(charMap['description'])
                  : null,
            ),
            voiceProfilesJson: jsonEncode(convertedProfiles),
            color: Value(charMap['color'] as String? ?? '#FF9800'),
            isChild: Value(charMap['isChild'] as bool? ?? false),
            isMale: Value(charMap['isMale'] as bool? ?? false),
          ),
        );
      }

      debugPrint('SeedService: Seeded ${charactersList.length} characters from $_charactersFile');
    } catch (e) {
      debugPrint('SeedService: Error seeding characters from $_charactersFile: $e');
      rethrow;
    }
  }

  Future<void> _seedLesson(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Insert lesson
      final lessonId = await db.into(db.lessons).insert(
        LessonsCompanion.insert(
          lessonId: json['id'] as String,
          topic: json['topic'] as String,
          difficulty: Value(json['difficulty'] as int),
          tags: jsonEncode(json['tags'] ?? []),
          titleJson: jsonEncode(json['title']),
          descriptionJson: jsonEncode(json['description']),
        ),
      );

      // Insert scenes
      final scenes = json['scenes'] as List;
      for (var i = 0; i < scenes.length; i++) {
        final sceneJson = scenes[i] as Map<String, dynamic>;
        await _insertScene(lessonId, sceneJson, i);
      }

      debugPrint('SeedService: Seeded lesson "${json['id']}" with ${scenes.length} scenes');
    } catch (e) {
      debugPrint('SeedService: Error seeding lesson from $assetPath: $e');
      rethrow;
    }
  }

  Future<void> _insertScene(int lessonId, Map<String, dynamic> json, int orderIndex) async {
    await db.into(db.scenes).insert(
      ScenesCompanion.insert(
        lessonId: lessonId,
        orderIndex: orderIndex,
        character: Value(json['character'] as String?),
        animation: Value(json['animation'] as String?),
        emotion: Value(json['emotion'] as String?),
        secondCharacter: Value(json['secondCharacter'] as String?),
        secondAnimation: Value(json['secondAnimation'] as String?),
        secondEmotion: Value(json['secondEmotion'] as String?),
        dialogueJson: Value(_encodeOrNull(json['dialogue'])),
        buttonTitleJson: Value(_encodeOrNull(json['buttonTitle'])),
        duration: Value(json['duration'] as int?),
        tone: Value(json['tone'] as String?),
        transitionType: Value(json['transitionType'] as String?),
        isQuestion: Value(json['isQuestion'] as bool? ?? false),
        isPause: Value(json['isPause'] as bool? ?? false),
        correctAnswer: Value(json['correctAnswer'] as int?),
        correctAnswerTextJson: Value(_encodeOrNull(json['correctAnswerText'])),
        answerOptionsJson: Value(_encodeOrNull(json['answerOptions'])),
        waitForAnswer: Value(json['waitForAnswer'] as bool? ?? false),
        showPreviousAnimals: Value(json['showPreviousAnimals'] as bool? ?? false),
        animalsJson: Value(_encodeOrNull(json['animals'])),
      ),
    );
  }

  String? _encodeOrNull(dynamic value) {
    if (value == null) return null;
    return jsonEncode(value);
  }

  /// Reset and reseed database (for settings/debug)
  Future<void> resetAndReseed() async {
    debugPrint('SeedService: Resetting database and reseeding');

    // Delete all data (order matters due to foreign keys)
    await db.delete(db.audioCaches).go();
    await db.delete(db.scenes).go();
    await db.delete(db.lessons).go();
    await db.delete(db.characters).go();

    // Reseed characters
    await _seedCharacters();

    // Reseed lessons
    for (final file in _lessonFiles) {
      await _seedLesson(file);
    }

    debugPrint('SeedService: Reset and reseed complete');
  }

  /// Reset only characters (keeps lessons)
  Future<void> resetCharacters() async {
    debugPrint('SeedService: Resetting characters');
    await db.delete(db.characters).go();
    await _seedCharacters();
    debugPrint('SeedService: Characters reset complete');
  }

  /// Get count of lessons in database
  Future<int> getLessonCount() async {
    return await db.managers.lessons.count();
  }

  /// Get count of scenes in database
  Future<int> getSceneCount() async {
    return await db.managers.scenes.count();
  }

  /// Get count of characters in database
  Future<int> getCharacterCount() async {
    return await db.managers.characters.count();
  }
}
