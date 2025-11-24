import 'package:elli_friends_app/features/lessons/data/datasources/lesson_drift_data_source.dart';
import 'package:elli_friends_app/features/lessons/data/datasources/lesson_local_data_source.dart';
import 'package:elli_friends_app/features/lessons/data/models/lesson_model.dart';
import 'package:elli_friends_app/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/lesson.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLessonDriftDataSource extends Mock implements LessonDriftDataSource {}

class MockLessonLocalDataSource extends Mock implements LessonLocalDataSource {}

void main() {
  late LessonRepositoryImpl repository;
  late MockLessonDriftDataSource mockDriftDataSource;
  late MockLessonLocalDataSource mockLocalDataSource;

  setUp(() {
    mockDriftDataSource = MockLessonDriftDataSource();
    mockLocalDataSource = MockLessonLocalDataSource();
    repository = LessonRepositoryImpl(
      driftDataSource: mockDriftDataSource,
      localDataSource: mockLocalDataSource,
    );
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
      test('should return Lesson from Drift when available', () async {
        // Arrange
        when(() => mockDriftDataSource.getLessonById(any(), languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => tLessonModel);

        // Act
        final result = await repository.getLessonById(tLessonId);

        // Assert
        expect(result, equals(tLessonModel));
        verify(() => mockDriftDataSource.getLessonById(tLessonId, languageCode: null));
        verifyZeroInteractions(mockLocalDataSource);
      });

      test('should fallback to LocalDataSource when Drift returns null', () async {
        // Arrange
        when(() => mockDriftDataSource.getLessonById(any(), languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.getLessonById(any(), languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => tLessonModel);

        // Act
        final result = await repository.getLessonById(tLessonId);

        // Assert
        expect(result, equals(tLessonModel));
        verify(() => mockDriftDataSource.getLessonById(tLessonId, languageCode: null));
        verify(() => mockLocalDataSource.getLessonById(tLessonId, languageCode: null));
      });

      test('should fallback to LocalDataSource when Drift throws', () async {
        // Arrange
        when(() => mockDriftDataSource.getLessonById(any(), languageCode: any(named: 'languageCode')))
            .thenThrow(Exception('Database error'));
        when(() => mockLocalDataSource.getLessonById(any(), languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => tLessonModel);

        // Act
        final result = await repository.getLessonById(tLessonId);

        // Assert
        expect(result, equals(tLessonModel));
        verify(() => mockDriftDataSource.getLessonById(tLessonId, languageCode: null));
        verify(() => mockLocalDataSource.getLessonById(tLessonId, languageCode: null));
      });

      test('should throw when both sources fail', () async {
        // Arrange - repository without fallback
        final repoWithoutFallback = LessonRepositoryImpl(
          driftDataSource: mockDriftDataSource,
        );
        when(() => mockDriftDataSource.getLessonById(any(), languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () async => await repoWithoutFallback.getLessonById(tLessonId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getAllLessons', () {
      final tLessonList = [tLessonModel];

      test('should return list from Drift when available', () async {
        // Arrange
        when(() => mockDriftDataSource.getAllLessons(languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => tLessonList);

        // Act
        final result = await repository.getAllLessons();

        // Assert
        expect(result, equals(tLessonList));
        expect(result, isA<List<Lesson>>());
        verify(() => mockDriftDataSource.getAllLessons(languageCode: null));
        verifyZeroInteractions(mockLocalDataSource);
      });

      test('should fallback to LocalDataSource when Drift returns empty', () async {
        // Arrange
        when(() => mockDriftDataSource.getAllLessons(languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => []);
        when(() => mockLocalDataSource.getAllLessons(languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => tLessonList);

        // Act
        final result = await repository.getAllLessons();

        // Assert
        expect(result, equals(tLessonList));
        verify(() => mockDriftDataSource.getAllLessons(languageCode: null));
        verify(() => mockLocalDataSource.getAllLessons(languageCode: null));
      });

      test('should fallback to LocalDataSource when Drift throws', () async {
        // Arrange
        when(() => mockDriftDataSource.getAllLessons(languageCode: any(named: 'languageCode')))
            .thenThrow(Exception('Database error'));
        when(() => mockLocalDataSource.getAllLessons(languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => tLessonList);

        // Act
        final result = await repository.getAllLessons();

        // Assert
        expect(result, equals(tLessonList));
      });

      test('should return empty list when no fallback and Drift empty', () async {
        // Arrange - repository without fallback
        final repoWithoutFallback = LessonRepositoryImpl(
          driftDataSource: mockDriftDataSource,
        );
        when(() => mockDriftDataSource.getAllLessons(languageCode: any(named: 'languageCode')))
            .thenAnswer((_) async => []);

        // Act
        final result = await repoWithoutFallback.getAllLessons();

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}
