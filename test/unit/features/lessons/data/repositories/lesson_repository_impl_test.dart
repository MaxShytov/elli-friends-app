import 'package:elli_friends_app/features/lessons/data/datasources/lesson_local_data_source.dart';
import 'package:elli_friends_app/features/lessons/data/models/lesson_model.dart';
import 'package:elli_friends_app/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/lesson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLessonLocalDataSource extends Mock implements LessonLocalDataSource {}

void main() {
  late LessonRepositoryImpl repository;
  late MockLessonLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockLessonLocalDataSource();
    repository = LessonRepositoryImpl(mockLocalDataSource);
  });

  group('LessonRepositoryImpl', () {
    const tLessonModel = LessonModel(
      id: 'test_lesson',
      title: 'Test Lesson',
      topic: 'testing',
      description: 'A test lesson',
      difficulty: 1,
      scenes: [
        SceneModel(
          character: 'bono',
          dialogue: 'Hello!',
          duration: 2,
          tone: 'friendly',
        ),
      ],
      tags: ['test'],
    );

    const String tLessonId = 'test_lesson';

    group('getLessonById', () {
      test('should return Lesson when call to data source is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.getLessonById(any()))
            .thenAnswer((_) async => tLessonModel);

        // Act
        final result = await repository.getLessonById(tLessonId);

        // Assert
        expect(result, equals(tLessonModel));
        verify(() => mockLocalDataSource.getLessonById(tLessonId));
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should throw Exception when call to data source fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getLessonById(any()))
            .thenThrow(Exception('Failed to load lesson'));

        // Act & Assert
        expect(
          () async => await repository.getLessonById(tLessonId),
          throwsA(isA<Exception>()),
        );
        verify(() => mockLocalDataSource.getLessonById(tLessonId));
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });

    group('getAllLessons', () {
      final tLessonList = [tLessonModel];

      test('should return list of Lessons when call to data source is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllLessons())
            .thenAnswer((_) async => tLessonList);

        // Act
        final result = await repository.getAllLessons();

        // Assert
        expect(result, equals(tLessonList));
        expect(result, isA<List<Lesson>>());
        verify(() => mockLocalDataSource.getAllLessons());
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should throw Exception when call to data source fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getAllLessons())
            .thenThrow(Exception('Failed to load lessons'));

        // Act & Assert
        expect(
          () async => await repository.getAllLessons(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockLocalDataSource.getAllLessons());
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });
  });
}
