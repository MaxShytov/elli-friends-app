import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLesson {
  final LessonRepository repository;

  GetLesson(this.repository);

  Future<Lesson> call(String lessonId) {
    return repository.getLessonById(lessonId);
  }
}
