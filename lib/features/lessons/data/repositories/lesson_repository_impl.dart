import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_local_data_source.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonLocalDataSource localDataSource;
  final String? languageCode;

  LessonRepositoryImpl(this.localDataSource, {this.languageCode});

  @override
  Future<Lesson> getLessonById(String id) async {
    return await localDataSource.getLessonById(id, languageCode: languageCode);
  }

  @override
  Future<List<Lesson>> getAllLessons() async {
    return await localDataSource.getAllLessons(languageCode: languageCode);
  }
}
