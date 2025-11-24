import 'dart:convert';
import 'package:flutter/foundation.dart';
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
        'assets/data/lessons/lesson_$id.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return LessonModel.fromJson(jsonMap, locale: locale);
    } catch (e) {
      throw Exception('Failed to load lesson: $e');
    }
  }

  @override
  Future<List<LessonModel>> getAllLessons({String? languageCode}) async {
    // Список доступных уроков
    final lessonIds = ['counting', 'subtraction'];

    final lessons = <LessonModel>[];
    for (final id in lessonIds) {
      try {
        final lesson = await getLessonById(id, languageCode: languageCode);
        lessons.add(lesson);
      } catch (e) {
        // Пропускаем урок, если не удалось загрузить
        debugPrint('Failed to load lesson $id: $e');
      }
    }

    return lessons;
  }
}
