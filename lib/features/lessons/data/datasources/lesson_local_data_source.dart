import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson_model.dart';

abstract class LessonLocalDataSource {
  Future<LessonModel> getLessonById(String id, {String? languageCode});
  Future<List<LessonModel>> getAllLessons({String? languageCode});
}

class LessonLocalDataSourceImpl implements LessonLocalDataSource {
  @override
  Future<LessonModel> getLessonById(String id, {String? languageCode}) async {
    try {
      final locale = languageCode ?? 'en';
      final jsonString = await rootBundle.loadString(
        'assets/data/lessons/$locale/lesson_$id.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return LessonModel.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load lesson: $e');
    }
  }

  @override
  Future<List<LessonModel>> getAllLessons({String? languageCode}) async {
    // Пока хардкодим список уроков
    final lessonIds = ['counting'];

    final lessons = <LessonModel>[];
    for (final id in lessonIds) {
      final lesson = await getLessonById(id, languageCode: languageCode);
      lessons.add(lesson);
    }

    return lessons;
  }
}
