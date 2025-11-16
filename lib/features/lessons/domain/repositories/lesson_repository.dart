import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<Lesson> getLessonById(String id);
  Future<List<Lesson>> getAllLessons();
}
