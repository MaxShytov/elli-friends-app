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
  ];

  /// Check if database needs seeding (empty database)
  Future<bool> needsSeed() async {
    final count = await db.managers.lessons.count();
    return count == 0;
  }

  /// Seed database from JSON assets on first launch
  Future<void> seedFromAssets() async {
    if (!await needsSeed()) {
      debugPrint('SeedService: Database already seeded, skipping');
      return;
    }

    debugPrint('SeedService: Starting database seed from JSON assets');

    for (final file in _lessonFiles) {
      await _seedLesson(file);
    }

    final lessonCount = await db.managers.lessons.count();
    final sceneCount = await db.managers.scenes.count();
    debugPrint(
      'SeedService: Seed complete. Lessons: $lessonCount, Scenes: $sceneCount',
    );
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

    // Delete all data
    await db.delete(db.audioCaches).go();
    await db.delete(db.scenes).go();
    await db.delete(db.lessons).go();

    // Reseed
    for (final file in _lessonFiles) {
      await _seedLesson(file);
    }

    debugPrint('SeedService: Reset and reseed complete');
  }

  /// Get count of lessons in database
  Future<int> getLessonCount() async {
    return await db.managers.lessons.count();
  }

  /// Get count of scenes in database
  Future<int> getSceneCount() async {
    return await db.managers.scenes.count();
  }
}
