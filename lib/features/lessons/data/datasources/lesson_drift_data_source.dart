import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/lesson_model.dart';

/// Raw scene data with all localizations
class RawSceneData {
  final SceneModel scene;
  final Map<String, String> dialogues;
  final Map<String, String> buttonTitles;

  RawSceneData({
    required this.scene,
    required this.dialogues,
    required this.buttonTitles,
  });
}

/// Raw lesson data with all localizations
class RawLessonData {
  final LessonModel lesson;
  final List<RawSceneData> scenes;

  RawLessonData({required this.lesson, required this.scenes});
}

/// Abstract interface for Drift-based lesson data source
abstract class LessonDriftDataSource {
  /// Get all lessons from the database
  Future<List<LessonModel>> getAllLessons({String? languageCode});

  /// Get a specific lesson by ID
  Future<LessonModel?> getLessonById(String lessonId, {String? languageCode});

  /// Get a lesson with all raw localization data (for editing)
  Future<RawLessonData?> getLessonWithLocalizations(String lessonId);

  /// Save or update a lesson
  Future<void> saveLesson(LessonModel lesson);

  /// Save lesson with full localization data for scenes
  Future<void> saveLessonWithLocalizations({
    required LessonModel lesson,
    required List<Map<String, String>> sceneDialogues,
    required List<Map<String, String>> sceneButtonTitles,
  });

  /// Update a specific scene
  Future<void> updateScene(int sceneId, SceneModel scene);

  /// Delete a scene
  Future<void> deleteScene(int sceneId);

  /// Reorder scenes in a lesson
  Future<void> reorderScenes(String lessonId, List<int> newOrder);

  /// Watch all lessons for reactive updates
  Stream<List<LessonModel>> watchAllLessons({String? languageCode});
}

/// Implementation of LessonDriftDataSource using Drift database
class LessonDriftDataSourceImpl implements LessonDriftDataSource {
  final AppDatabase db;

  LessonDriftDataSourceImpl(this.db);

  @override
  Future<List<LessonModel>> getAllLessons({String? languageCode}) async {
    final locale = languageCode ?? 'en';

    // Get all lessons ordered by id
    final lessonRows = await db.select(db.lessons).get();

    final lessons = <LessonModel>[];

    for (final lessonRow in lessonRows) {
      // Get scenes for this lesson
      final sceneRows = await (db.select(db.scenes)
            ..where((s) => s.lessonId.equals(lessonRow.id))
            ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
          .get();

      final lesson = _lessonFromRow(lessonRow, sceneRows, locale);
      lessons.add(lesson);
    }

    return lessons;
  }

  @override
  Future<LessonModel?> getLessonById(
    String lessonId, {
    String? languageCode,
  }) async {
    final locale = languageCode ?? 'en';

    // Get lesson by lessonId (the string identifier, not the auto-increment id)
    final lessonRow = await (db.select(db.lessons)
          ..where((l) => l.lessonId.equals(lessonId)))
        .getSingleOrNull();

    if (lessonRow == null) return null;

    // Get scenes for this lesson
    final sceneRows = await (db.select(db.scenes)
          ..where((s) => s.lessonId.equals(lessonRow.id))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .get();

    return _lessonFromRow(lessonRow, sceneRows, locale);
  }

  @override
  Future<RawLessonData?> getLessonWithLocalizations(String lessonId) async {
    // Get lesson by lessonId
    final lessonRow = await (db.select(db.lessons)
          ..where((l) => l.lessonId.equals(lessonId)))
        .getSingleOrNull();

    if (lessonRow == null) return null;

    // Get scenes for this lesson
    final sceneRows = await (db.select(db.scenes)
          ..where((s) => s.lessonId.equals(lessonRow.id))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .get();

    // Build lesson model (using 'en' as default)
    final lesson = _lessonFromRow(lessonRow, sceneRows, 'en');

    // Build raw scene data with all localizations
    final rawScenes = sceneRows.map((sceneRow) {
      final scene = _sceneFromRow(sceneRow, 'en');
      final dialogues = _parseJsonMapOrNull(sceneRow.dialogueJson);
      final buttonTitles = _parseJsonMapOrNull(sceneRow.buttonTitleJson);

      return RawSceneData(
        scene: scene,
        dialogues: dialogues?.map((k, v) => MapEntry(k, v.toString())) ?? {},
        buttonTitles: buttonTitles?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      );
    }).toList();

    return RawLessonData(lesson: lesson, scenes: rawScenes);
  }

  @override
  Future<void> saveLesson(LessonModel lesson) async {
    await db.transaction(() async {
      // Check if lesson exists
      final existingLesson = await (db.select(db.lessons)
            ..where((l) => l.lessonId.equals(lesson.id)))
          .getSingleOrNull();

      int dbLessonId;

      if (existingLesson != null) {
        // Update existing lesson
        await (db.update(db.lessons)
              ..where((l) => l.lessonId.equals(lesson.id)))
            .write(
          LessonsCompanion(
            topic: Value(lesson.topic),
            difficulty: Value(lesson.difficulty),
            tags: Value(jsonEncode(lesson.tags)),
            titleJson: Value(jsonEncode({'en': lesson.title})),
            descriptionJson: Value(jsonEncode({'en': lesson.description})),
            updatedAt: Value(DateTime.now()),
          ),
        );
        dbLessonId = existingLesson.id;
      } else {
        // Insert new lesson
        dbLessonId = await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            lessonId: lesson.id,
            topic: lesson.topic,
            difficulty: Value(lesson.difficulty),
            tags: jsonEncode(lesson.tags),
            titleJson: jsonEncode({'en': lesson.title}),
            descriptionJson: jsonEncode({'en': lesson.description}),
          ),
        );
      }

      // Delete existing scenes and re-insert
      await (db.delete(db.scenes)..where((s) => s.lessonId.equals(dbLessonId)))
          .go();

      // Insert scenes
      for (var i = 0; i < lesson.scenes.length; i++) {
        final scene = lesson.scenes[i] as SceneModel;
        await _insertScene(dbLessonId, scene, i);
      }
    });
  }

  @override
  Future<void> saveLessonWithLocalizations({
    required LessonModel lesson,
    required List<Map<String, String>> sceneDialogues,
    required List<Map<String, String>> sceneButtonTitles,
  }) async {
    await db.transaction(() async {
      // Check if lesson exists
      final existingLesson = await (db.select(db.lessons)
            ..where((l) => l.lessonId.equals(lesson.id)))
          .getSingleOrNull();

      int dbLessonId;

      if (existingLesson != null) {
        // Update existing lesson
        await (db.update(db.lessons)
              ..where((l) => l.lessonId.equals(lesson.id)))
            .write(
          LessonsCompanion(
            topic: Value(lesson.topic),
            difficulty: Value(lesson.difficulty),
            tags: Value(jsonEncode(lesson.tags)),
            titleJson: Value(jsonEncode({'en': lesson.title})),
            descriptionJson: Value(jsonEncode({'en': lesson.description})),
            updatedAt: Value(DateTime.now()),
          ),
        );
        dbLessonId = existingLesson.id;
      } else {
        // Insert new lesson
        dbLessonId = await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            lessonId: lesson.id,
            topic: lesson.topic,
            difficulty: Value(lesson.difficulty),
            tags: jsonEncode(lesson.tags),
            titleJson: jsonEncode({'en': lesson.title}),
            descriptionJson: jsonEncode({'en': lesson.description}),
          ),
        );
      }

      // Delete existing scenes and re-insert
      await (db.delete(db.scenes)..where((s) => s.lessonId.equals(dbLessonId)))
          .go();

      // Insert scenes with full localization data
      for (var i = 0; i < lesson.scenes.length; i++) {
        final scene = lesson.scenes[i] as SceneModel;
        final dialogues = i < sceneDialogues.length ? sceneDialogues[i] : <String, String>{};
        final buttonTitles = i < sceneButtonTitles.length ? sceneButtonTitles[i] : <String, String>{};
        await _insertSceneWithLocalizations(dbLessonId, scene, i, dialogues, buttonTitles);
      }
    });
  }

  @override
  Future<void> updateScene(int sceneId, SceneModel scene) async {
    await (db.update(db.scenes)..where((s) => s.id.equals(sceneId))).write(
      ScenesCompanion(
        character: Value(scene.character),
        animation: Value(scene.animation),
        emotion: Value(scene.emotion),
        secondCharacter: Value(scene.secondCharacter),
        secondAnimation: Value(scene.secondAnimation),
        secondEmotion: Value(scene.secondEmotion),
        dialogueJson: Value(
          scene.dialogue != null ? jsonEncode({'en': scene.dialogue}) : null,
        ),
        buttonTitleJson: Value(
          scene.buttonTitle != null
              ? jsonEncode({'en': scene.buttonTitle})
              : null,
        ),
        duration: Value(scene.duration),
        tone: Value(scene.tone),
        transitionType: Value(scene.transitionType),
        isQuestion: Value(scene.isQuestion),
        isPause: Value(scene.isPause),
        correctAnswer: Value(scene.correctAnswer),
        correctAnswerTextJson: Value(
          scene.correctAnswerText != null
              ? jsonEncode({'en': scene.correctAnswerText})
              : null,
        ),
        answerOptionsJson: Value(
          scene.answerOptions != null
              ? jsonEncode(
                  scene.answerOptions!
                      .map((o) => (o as AnswerOptionModel).toJson())
                      .toList(),
                )
              : null,
        ),
        waitForAnswer: Value(scene.waitForAnswer),
        showPreviousAnimals: Value(scene.showPreviousAnimals),
        animalsJson: Value(
          scene.animals != null
              ? jsonEncode(
                  scene.animals!.map((a) => (a as AnimalModel).toJson()).toList(),
                )
              : null,
        ),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteScene(int sceneId) async {
    await (db.delete(db.scenes)..where((s) => s.id.equals(sceneId))).go();
  }

  @override
  Future<void> reorderScenes(String lessonId, List<int> newOrder) async {
    await db.transaction(() async {
      for (var i = 0; i < newOrder.length; i++) {
        final sceneId = newOrder[i];
        await (db.update(db.scenes)..where((s) => s.id.equals(sceneId))).write(
          ScenesCompanion(orderIndex: Value(i)),
        );
      }
    });
  }

  @override
  Stream<List<LessonModel>> watchAllLessons({String? languageCode}) {
    final locale = languageCode ?? 'en';

    return db.select(db.lessons).watch().asyncMap((lessonRows) async {
      final lessons = <LessonModel>[];

      for (final lessonRow in lessonRows) {
        final sceneRows = await (db.select(db.scenes)
              ..where((s) => s.lessonId.equals(lessonRow.id))
              ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
            .get();

        lessons.add(_lessonFromRow(lessonRow, sceneRows, locale));
      }

      return lessons;
    });
  }

  // Helper: Convert database row to LessonModel
  LessonModel _lessonFromRow(
    Lesson lessonRow,
    List<Scene> sceneRows,
    String locale,
  ) {
    final titleMap = _parseJsonMap(lessonRow.titleJson);
    final descriptionMap = _parseJsonMap(lessonRow.descriptionJson);
    final tags = _parseJsonList(lessonRow.tags);

    return LessonModel(
      id: lessonRow.lessonId,
      title: _getLocalizedString(titleMap, locale),
      topic: lessonRow.topic,
      description: _getLocalizedString(descriptionMap, locale),
      difficulty: lessonRow.difficulty,
      tags: tags,
      scenes: sceneRows.map((s) => _sceneFromRow(s, locale)).toList(),
    );
  }

  // Helper: Convert database row to SceneModel
  SceneModel _sceneFromRow(Scene sceneRow, String locale) {
    final dialogueMap = _parseJsonMapOrNull(sceneRow.dialogueJson);
    final buttonTitleMap = _parseJsonMapOrNull(sceneRow.buttonTitleJson);
    final correctAnswerTextMap = _parseJsonMapOrNull(sceneRow.correctAnswerTextJson);
    final answerOptionsJson = _parseJsonListOrNull(sceneRow.answerOptionsJson);
    final animalsJson = _parseJsonListOrNull(sceneRow.animalsJson);

    return SceneModel(
      character: sceneRow.character,
      dialogue:
          dialogueMap != null ? _getLocalizedString(dialogueMap, locale) : null,
      duration: sceneRow.duration,
      tone: sceneRow.tone,
      animation: sceneRow.animation,
      emotion: sceneRow.emotion,
      transitionType: sceneRow.transitionType,
      isQuestion: sceneRow.isQuestion,
      isPause: sceneRow.isPause,
      correctAnswer: sceneRow.correctAnswer,
      correctAnswerText: correctAnswerTextMap != null
          ? _getLocalizedString(correctAnswerTextMap, locale)
          : null,
      answerOptions: answerOptionsJson
          ?.map((opt) => AnswerOptionModel.fromJson(opt as Map<String, dynamic>, locale: locale))
          .toList(),
      waitForAnswer: sceneRow.waitForAnswer,
      showPreviousAnimals: sceneRow.showPreviousAnimals,
      buttonTitle: buttonTitleMap != null
          ? _getLocalizedString(buttonTitleMap, locale)
          : null,
      secondCharacter: sceneRow.secondCharacter,
      secondAnimation: sceneRow.secondAnimation,
      secondEmotion: sceneRow.secondEmotion,
      animals: animalsJson
          ?.map((a) => AnimalModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  // Helper: Insert a scene into the database
  Future<void> _insertScene(
    int lessonId,
    SceneModel scene,
    int orderIndex,
  ) async {
    await db.into(db.scenes).insert(
          ScenesCompanion.insert(
            lessonId: lessonId,
            orderIndex: orderIndex,
            character: Value(scene.character),
            animation: Value(scene.animation),
            emotion: Value(scene.emotion),
            secondCharacter: Value(scene.secondCharacter),
            secondAnimation: Value(scene.secondAnimation),
            secondEmotion: Value(scene.secondEmotion),
            dialogueJson: Value(
              scene.dialogue != null
                  ? jsonEncode({'en': scene.dialogue})
                  : null,
            ),
            buttonTitleJson: Value(
              scene.buttonTitle != null
                  ? jsonEncode({'en': scene.buttonTitle})
                  : null,
            ),
            duration: Value(scene.duration),
            tone: Value(scene.tone),
            transitionType: Value(scene.transitionType),
            isQuestion: Value(scene.isQuestion),
            isPause: Value(scene.isPause),
            correctAnswer: Value(scene.correctAnswer),
            correctAnswerTextJson: Value(
              scene.correctAnswerText != null
                  ? jsonEncode({'en': scene.correctAnswerText})
                  : null,
            ),
            answerOptionsJson: Value(
              scene.answerOptions != null
                  ? jsonEncode(
                      scene.answerOptions!
                          .map((o) => (o as AnswerOptionModel).toJson())
                          .toList(),
                    )
                  : null,
            ),
            waitForAnswer: Value(scene.waitForAnswer),
            showPreviousAnimals: Value(scene.showPreviousAnimals),
            animalsJson: Value(
              scene.animals != null
                  ? jsonEncode(
                      scene.animals!
                          .map((a) => (a as AnimalModel).toJson())
                          .toList(),
                    )
                  : null,
            ),
          ),
        );
  }

  // Helper: Insert a scene with full localization data
  Future<void> _insertSceneWithLocalizations(
    int lessonId,
    SceneModel scene,
    int orderIndex,
    Map<String, String> dialogues,
    Map<String, String> buttonTitles,
  ) async {
    await db.into(db.scenes).insert(
          ScenesCompanion.insert(
            lessonId: lessonId,
            orderIndex: orderIndex,
            character: Value(scene.character),
            animation: Value(scene.animation),
            emotion: Value(scene.emotion),
            secondCharacter: Value(scene.secondCharacter),
            secondAnimation: Value(scene.secondAnimation),
            secondEmotion: Value(scene.secondEmotion),
            dialogueJson: Value(
              dialogues.isNotEmpty ? jsonEncode(dialogues) : null,
            ),
            buttonTitleJson: Value(
              buttonTitles.isNotEmpty ? jsonEncode(buttonTitles) : null,
            ),
            duration: Value(scene.duration),
            tone: Value(scene.tone),
            transitionType: Value(scene.transitionType),
            isQuestion: Value(scene.isQuestion),
            isPause: Value(scene.isPause),
            correctAnswer: Value(scene.correctAnswer),
            correctAnswerTextJson: Value(
              scene.correctAnswerText != null
                  ? jsonEncode({'en': scene.correctAnswerText})
                  : null,
            ),
            answerOptionsJson: Value(
              scene.answerOptions != null
                  ? jsonEncode(
                      scene.answerOptions!
                          .map((o) => (o as AnswerOptionModel).toJson())
                          .toList(),
                    )
                  : null,
            ),
            waitForAnswer: Value(scene.waitForAnswer),
            showPreviousAnimals: Value(scene.showPreviousAnimals),
            animalsJson: Value(
              scene.animals != null
                  ? jsonEncode(
                      scene.animals!
                          .map((a) => (a as AnimalModel).toJson())
                          .toList(),
                    )
                  : null,
            ),
          ),
        );
  }

  // JSON parsing helpers
  Map<String, dynamic> _parseJsonMap(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Map<String, dynamic>? _parseJsonMapOrNull(String? json) {
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  List<String> _parseJsonList(String json) {
    final list = jsonDecode(json) as List;
    return list.map((e) => e.toString()).toList();
  }

  List<dynamic>? _parseJsonListOrNull(String? json) {
    if (json == null) return null;
    return jsonDecode(json) as List<dynamic>;
  }

  String _getLocalizedString(Map<String, dynamic> map, String locale) {
    return map[locale] as String? ?? map['en'] as String? ?? '';
  }
}
