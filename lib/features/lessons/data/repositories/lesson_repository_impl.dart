import 'package:flutter/foundation.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_drift_data_source.dart';
import '../datasources/lesson_local_data_source.dart';

/// Repository implementation that uses Drift database as primary source
/// with fallback to JSON assets if database fails
class LessonRepositoryImpl implements LessonRepository {
  final LessonDriftDataSource driftDataSource;
  final LessonLocalDataSource? localDataSource;
  final String? languageCode;

  LessonRepositoryImpl({
    required this.driftDataSource,
    this.localDataSource,
    this.languageCode,
  });

  @override
  Future<Lesson> getLessonById(String id) async {
    try {
      // Try to get from Drift database first
      final lesson = await driftDataSource.getLessonById(
        id,
        languageCode: languageCode,
      );

      if (lesson != null) {
        return lesson;
      }

      // If not found in database, try local data source (JSON) as fallback
      if (localDataSource != null) {
        debugPrint('LessonRepository: Lesson $id not in DB, falling back to JSON');
        return await localDataSource!.getLessonById(id, languageCode: languageCode);
      }

      throw Exception('Lesson not found: $id');
    } catch (e) {
      // Fallback to JSON if database fails
      if (localDataSource != null) {
        debugPrint('LessonRepository: DB error, falling back to JSON: $e');
        return await localDataSource!.getLessonById(id, languageCode: languageCode);
      }
      rethrow;
    }
  }

  @override
  Future<List<Lesson>> getAllLessons() async {
    try {
      // Try to get from Drift database first
      final lessons = await driftDataSource.getAllLessons(
        languageCode: languageCode,
      );

      if (lessons.isNotEmpty) {
        return lessons;
      }

      // If database is empty, try local data source (JSON) as fallback
      if (localDataSource != null) {
        debugPrint('LessonRepository: DB empty, falling back to JSON');
        return await localDataSource!.getAllLessons(languageCode: languageCode);
      }

      return [];
    } catch (e) {
      // Fallback to JSON if database fails
      if (localDataSource != null) {
        debugPrint('LessonRepository: DB error, falling back to JSON: $e');
        return await localDataSource!.getAllLessons(languageCode: languageCode);
      }
      rethrow;
    }
  }
}
