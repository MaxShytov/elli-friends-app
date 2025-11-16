import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/lesson.dart';
import 'package:elli_friends_app/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:elli_friends_app/features/lessons/domain/usecases/get_all_lessons.dart';

// Mock classes
class MockLessonRepository extends Mock implements LessonRepository {}

void main() {
  late GetAllLessons useCase;
  late MockLessonRepository mockRepository;

  setUp(() {
    mockRepository = MockLessonRepository();
    useCase = GetAllLessons(mockRepository);
  });

  group('GetAllLessons', () {
    final testLessons = [
      const Lesson(
        id: 'counting-1',
        title: 'Learn to Count to 3',
        topic: 'counting',
        description: 'Introduction to counting with animals',
        difficulty: 1,
        scenes: [
          Scene(
            character: 'elli',
            dialogue: 'Let\'s count together!',
            duration: 3000,
          ),
        ],
        tags: ['counting', 'beginner'],
      ),
      const Lesson(
        id: 'counting-2',
        title: 'Count to 5',
        topic: 'counting',
        description: 'Advanced counting',
        difficulty: 2,
        scenes: [
          Scene(
            character: 'elli',
            dialogue: 'Let\'s count more!',
            duration: 3000,
          ),
        ],
        tags: ['counting', 'intermediate'],
      ),
    ];

    test('should get all lessons from the repository', () async {
      // Arrange
      when(() => mockRepository.getAllLessons())
          .thenAnswer((_) async => testLessons);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testLessons);
      expect(result.length, 2);
      verify(() => mockRepository.getAllLessons()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no lessons available', () async {
      // Arrange
      when(() => mockRepository.getAllLessons())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getAllLessons()).called(1);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(() => mockRepository.getAllLessons())
          .thenThrow(Exception('Failed to load lessons'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsException,
      );
      verify(() => mockRepository.getAllLessons()).called(1);
    });
  });
}
