import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/lesson.dart';
import 'package:elli_friends_app/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:elli_friends_app/features/lessons/domain/usecases/get_lesson.dart';

// Mock classes
class MockLessonRepository extends Mock implements LessonRepository {}

void main() {
  late GetLesson useCase;
  late MockLessonRepository mockRepository;

  setUp(() {
    mockRepository = MockLessonRepository();
    useCase = GetLesson(mockRepository);
  });

  group('GetLesson', () {
    const testLessonId = 'counting-1';
    final testLesson = Lesson(
      id: testLessonId,
      title: 'Learn to Count to 3',
      topic: 'counting',
      description: 'Introduction to counting with animals',
      difficulty: 1,
      scenes: const [
        Scene(
          character: 'elli',
          dialogue: 'Let\'s count together!',
          duration: 3000,
        ),
      ],
      tags: const ['counting', 'beginner'],
    );

    test('should get lesson from the repository', () async {
      // Arrange
      when(() => mockRepository.getLessonById(testLessonId))
          .thenAnswer((_) async => testLesson);

      // Act
      final result = await useCase(testLessonId);

      // Assert
      expect(result, testLesson);
      verify(() => mockRepository.getLessonById(testLessonId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(() => mockRepository.getLessonById(testLessonId))
          .thenThrow(Exception('Lesson not found'));

      // Act & Assert
      expect(
        () => useCase(testLessonId),
        throwsException,
      );
      verify(() => mockRepository.getLessonById(testLessonId)).called(1);
    });
  });
}
