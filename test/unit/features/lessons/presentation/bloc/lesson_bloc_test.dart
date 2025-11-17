import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:elli_friends_app/features/lessons/presentation/bloc/lesson_bloc.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/lesson.dart';
import 'package:elli_friends_app/features/lessons/domain/usecases/get_lesson.dart';

// Mock GetLesson use case
class MockGetLesson extends Mock implements GetLesson {}

void main() {
  late LessonBloc lessonBloc;
  late MockGetLesson mockGetLesson;

  // Test data
  final testLesson = Lesson(
    id: 'test_lesson',
    title: 'Test Lesson',
    topic: 'counting',
    description: 'Test description',
    difficulty: 1,
    scenes: [
      const Scene(
        character: 'bono',
        dialogue: 'Hello',
        duration: 2,
      ),
      const Scene(
        character: 'bono',
        dialogue: 'Question?',
        isQuestion: true,
      ),
      const Scene(
        isPause: true,
        correctAnswer: 1,
        waitForAnswer: true,
      ),
      const Scene(
        character: 'hippo',
        dialogue: 'One!',
        duration: 2,
      ),
    ],
  );

  setUp(() {
    mockGetLesson = MockGetLesson();
    lessonBloc = LessonBloc(getLesson: mockGetLesson);
  });

  tearDown(() {
    lessonBloc.close();
  });

  group('LessonBloc', () {
    test('initial state is LessonInitial', () {
      expect(lessonBloc.state, isA<LessonInitial>());
    });

    group('LoadLesson', () {
      blocTest<LessonBloc, LessonState>(
        'emits [LessonLoading, LessonLoaded] when lesson is loaded successfully',
        build: () {
          when(() => mockGetLesson(any())).thenAnswer((_) async => testLesson);
          return lessonBloc;
        },
        act: (bloc) => bloc.add(LoadLesson('test_lesson')),
        expect: () => [
          isA<LessonLoading>(),
          isA<LessonLoaded>().having(
            (state) => state.lesson,
            'lesson',
            testLesson,
          ).having(
            (state) => state.currentSceneIndex,
            'currentSceneIndex',
            0,
          ),
        ],
        verify: (_) {
          verify(() => mockGetLesson('test_lesson')).called(1);
        },
      );

      blocTest<LessonBloc, LessonState>(
        'emits [LessonLoading, LessonError] when lesson loading fails',
        build: () {
          when(() => mockGetLesson(any())).thenThrow(Exception('Load failed'));
          return lessonBloc;
        },
        act: (bloc) => bloc.add(LoadLesson('test_lesson')),
        expect: () => [
          isA<LessonLoading>(),
          isA<LessonError>().having(
            (state) => state.message,
            'message',
            contains('Load failed'),
          ),
        ],
      );
    });

    group('NextScene', () {
      blocTest<LessonBloc, LessonState>(
        'moves to next scene when not at the end',
        build: () => lessonBloc,
        seed: () => LessonLoaded(lesson: testLesson, currentSceneIndex: 0),
        act: (bloc) => bloc.add(NextScene()),
        expect: () => [
          isA<LessonLoaded>().having(
            (state) => state.currentSceneIndex,
            'currentSceneIndex',
            1,
          ),
        ],
      );

      blocTest<LessonBloc, LessonState>(
        'emits LessonCompleted when at last scene',
        build: () => lessonBloc,
        seed: () => LessonLoaded(
          lesson: testLesson,
          currentSceneIndex: 3,
          correctAnswers: 1,
        ),
        act: (bloc) => bloc.add(NextScene()),
        expect: () => [
          isA<LessonCompleted>()
            .having((state) => state.totalQuestions, 'totalQuestions', 1)
            .having((state) => state.correctAnswers, 'correctAnswers', 1)
            .having((state) => state.stars, 'stars', 3),
        ],
      );
    });

    group('PreviousScene', () {
      blocTest<LessonBloc, LessonState>(
        'moves to previous scene when not at the start',
        build: () => lessonBloc,
        seed: () => LessonLoaded(lesson: testLesson, currentSceneIndex: 2),
        act: (bloc) => bloc.add(PreviousScene()),
        expect: () => [
          isA<LessonLoaded>().having(
            (state) => state.currentSceneIndex,
            'currentSceneIndex',
            1,
          ),
        ],
      );

      blocTest<LessonBloc, LessonState>(
        'does not move backward when at first scene',
        build: () => lessonBloc,
        seed: () => LessonLoaded(lesson: testLesson, currentSceneIndex: 0),
        act: (bloc) => bloc.add(PreviousScene()),
        expect: () => [],
      );
    });

    group('AnswerQuestion', () {
      blocTest<LessonBloc, LessonState>(
        'emits LessonAnswered with correct answer',
        build: () => lessonBloc,
        seed: () => LessonLoaded(lesson: testLesson, currentSceneIndex: 2),
        act: (bloc) => bloc.add(AnswerQuestion(1)),
        expect: () => [
          isA<LessonAnswered>()
            .having((state) => state.isCorrect, 'isCorrect', true)
            .having(
              (state) => state.loadedState.correctAnswers,
              'correctAnswers',
              1,
            ),
        ],
      );

      blocTest<LessonBloc, LessonState>(
        'emits LessonAnswered with incorrect answer',
        build: () => lessonBloc,
        seed: () => LessonLoaded(lesson: testLesson, currentSceneIndex: 2),
        act: (bloc) => bloc.add(AnswerQuestion(2)),
        expect: () => [
          isA<LessonAnswered>()
            .having((state) => state.isCorrect, 'isCorrect', false)
            .having(
              (state) => state.loadedState.correctAnswers,
              'correctAnswers',
              0,
            ),
        ],
      );
    });

    group('ResetLesson', () {
      blocTest<LessonBloc, LessonState>(
        'resets lesson to first scene',
        build: () => lessonBloc,
        seed: () => LessonLoaded(
          lesson: testLesson,
          currentSceneIndex: 2,
          correctAnswers: 5,
          stars: 2,
        ),
        act: (bloc) => bloc.add(ResetLesson()),
        expect: () => [
          isA<LessonLoaded>()
            .having((state) => state.currentSceneIndex, 'currentSceneIndex', 0)
            .having((state) => state.correctAnswers, 'correctAnswers', 0)
            .having((state) => state.stars, 'stars', 0),
        ],
      );
    });

    group('Star Calculation', () {
      test('calculates 3 stars for 100% correct', () {
        final lesson = Lesson(
          id: 'test',
          title: 'Test',
          topic: 'test',
          description: 'Test',
          difficulty: 1,
          scenes: [
            const Scene(isPause: true, correctAnswer: 1),
          ],
        );

        lessonBloc = LessonBloc(getLesson: mockGetLesson);
        final state = LessonLoaded(lesson: lesson, correctAnswers: 1);
        lessonBloc.emit(state);
        lessonBloc.add(NextScene());

        expectLater(
          lessonBloc.stream,
          emitsInOrder([
            isA<LessonCompleted>().having((s) => s.stars, 'stars', 3),
          ]),
        );
      });

      test('calculates 2 stars for 70-89% correct', () {
        final lesson = Lesson(
          id: 'test',
          title: 'Test',
          topic: 'test',
          description: 'Test',
          difficulty: 1,
          scenes: [
            const Scene(isPause: true, correctAnswer: 1),
            const Scene(isPause: true, correctAnswer: 2),
            const Scene(isPause: true, correctAnswer: 3),
            const Scene(isPause: true, correctAnswer: 4),
            const Scene(isPause: true, correctAnswer: 5),
          ],
        );

        lessonBloc = LessonBloc(getLesson: mockGetLesson);
        final state = LessonLoaded(
          lesson: lesson,
          currentSceneIndex: 4,
          correctAnswers: 4,
        );
        lessonBloc.emit(state);
        lessonBloc.add(NextScene());

        expectLater(
          lessonBloc.stream,
          emitsInOrder([
            isA<LessonCompleted>().having((s) => s.stars, 'stars', 2),
          ]),
        );
      });
    });
  });
}
