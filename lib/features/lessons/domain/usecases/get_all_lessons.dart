import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetAllLessons {
  final LessonRepository repository;

  GetAllLessons(this.repository);

  Future<List<Lesson>> call() {
    return repository.getAllLessons();
  }
}
