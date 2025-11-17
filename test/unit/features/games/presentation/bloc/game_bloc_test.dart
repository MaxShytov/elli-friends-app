import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:elli_friends_app/features/games/presentation/bloc/game_bloc.dart';
import 'package:elli_friends_app/features/games/domain/entities/game.dart';

void main() {
  group('GameBloc', () {
    late GameBloc gameBloc;
    late Game testGame;

    setUp(() {
      gameBloc = GameBloc();
      testGame = const Game(
        id: 'test-game',
        title: 'Test Game',
        type: 'counting',
        difficulty: 1,
        config: GameConfig(
          minNumber: 1,
          maxNumber: 5,
          questionsCount: 3,
        ),
      );
    });

    tearDown(() {
      gameBloc.close();
    });

    test('initial state is GameInitial', () {
      expect(gameBloc.state, equals(GameInitial()));
    });

    group('StartGame', () {
      blocTest<GameBloc, GameState>(
        'emits GameInProgress when StartGame is added',
        build: () => gameBloc,
        act: (bloc) => bloc.add(StartGame(testGame)),
        expect: () => [
          isA<GameInProgress>()
            .having((s) => s.game, 'game', testGame)
            .having((s) => s.currentQuestionIndex, 'currentQuestionIndex', 0)
            .having((s) => s.correctAnswers, 'correctAnswers', 0)
            .having((s) => s.score, 'score', 0)
            .having((s) => s.totalQuestions, 'totalQuestions', 3),
        ],
      );

      blocTest<GameBloc, GameState>(
        'generates a valid question when game starts',
        build: () => gameBloc,
        act: (bloc) => bloc.add(StartGame(testGame)),
        verify: (bloc) {
          final state = bloc.state as GameInProgress;
          expect(state.currentQuestion.number, greaterThanOrEqualTo(1));
          expect(state.currentQuestion.number, lessThanOrEqualTo(5));
          expect(state.currentQuestion.emoji, isNotEmpty);
        },
      );
    });

    group('AnswerQuestion', () {
      blocTest<GameBloc, GameState>(
        'emits GameAnswered with isCorrect=true when answer is correct',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          return GameInProgress(
            game: testGame,
            currentQuestion: question,
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: 3,
            score: 0,
          );
        },
        act: (bloc) => bloc.add(AnswerQuestion(3)),
        expect: () => [
          isA<GameAnswered>()
            .having((s) => s.isCorrect, 'isCorrect', true)
            .having((s) => s.correctAnswer, 'correctAnswer', 3),
          isA<GameInProgress>()
            .having((s) => s.correctAnswers, 'correctAnswers', 1)
            .having((s) => s.score, 'score', 10),
        ],
      );

      blocTest<GameBloc, GameState>(
        'emits GameAnswered with isCorrect=false when answer is incorrect',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          return GameInProgress(
            game: testGame,
            currentQuestion: question,
            currentQuestionIndex: 0,
            correctAnswers: 0,
            totalQuestions: 3,
            score: 0,
          );
        },
        act: (bloc) => bloc.add(AnswerQuestion(2)),
        expect: () => [
          isA<GameAnswered>()
            .having((s) => s.isCorrect, 'isCorrect', false)
            .having((s) => s.correctAnswer, 'correctAnswer', 3),
          isA<GameInProgress>()
            .having((s) => s.correctAnswers, 'correctAnswers', 0)
            .having((s) => s.score, 'score', 0),
        ],
      );
    });

    group('NextQuestion', () {
      blocTest<GameBloc, GameState>(
        'emits GameInProgress with new question when not last question',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          return GameInProgress(
            game: testGame,
            currentQuestion: question,
            currentQuestionIndex: 0,
            correctAnswers: 1,
            totalQuestions: 3,
            score: 10,
          );
        },
        act: (bloc) => bloc.add(NextQuestion()),
        expect: () => [
          isA<GameInProgress>()
            .having((s) => s.currentQuestionIndex, 'currentQuestionIndex', 1)
            .having((s) => s.correctAnswers, 'correctAnswers', 1)
            .having((s) => s.score, 'score', 10),
        ],
      );

      blocTest<GameBloc, GameState>(
        'emits GameCompleted when it is the last question',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          return GameInProgress(
            game: testGame,
            currentQuestion: question,
            currentQuestionIndex: 2, // Last question
            correctAnswers: 2,
            totalQuestions: 3,
            score: 20,
          );
        },
        act: (bloc) => bloc.add(NextQuestion()),
        expect: () => [
          isA<GameCompleted>()
            .having((s) => s.score, 'score', 20)
            .having((s) => s.correctAnswers, 'correctAnswers', 2)
            .having((s) => s.totalQuestions, 'totalQuestions', 3)
            .having((s) => s.stars, 'stars', 1), // 66% = 1 star
        ],
      );

      blocTest<GameBloc, GameState>(
        'calculates 3 stars for 90%+ correct answers',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          final game = const Game(
            id: 'test-game',
            title: 'Test Game',
            type: 'counting',
            difficulty: 1,
            config: GameConfig(
              minNumber: 1,
              maxNumber: 5,
              questionsCount: 10,
            ),
          );
          return GameInProgress(
            game: game,
            currentQuestion: question,
            currentQuestionIndex: 9, // Last question
            correctAnswers: 9,
            totalQuestions: 10,
            score: 90,
          );
        },
        act: (bloc) => bloc.add(NextQuestion()),
        expect: () => [
          isA<GameCompleted>()
            .having((s) => s.stars, 'stars', 3), // 90% = 3 stars
        ],
      );

      blocTest<GameBloc, GameState>(
        'calculates 2 stars for 70-89% correct answers',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          final game = const Game(
            id: 'test-game',
            title: 'Test Game',
            type: 'counting',
            difficulty: 1,
            config: GameConfig(
              minNumber: 1,
              maxNumber: 5,
              questionsCount: 10,
            ),
          );
          return GameInProgress(
            game: game,
            currentQuestion: question,
            currentQuestionIndex: 9, // Last question
            correctAnswers: 7,
            totalQuestions: 10,
            score: 70,
          );
        },
        act: (bloc) => bloc.add(NextQuestion()),
        expect: () => [
          isA<GameCompleted>()
            .having((s) => s.stars, 'stars', 2), // 70% = 2 stars
        ],
      );
    });

    group('RestartGame', () {
      blocTest<GameBloc, GameState>(
        'restarts the game with same configuration',
        build: () => gameBloc,
        seed: () {
          final question = const GameQuestion(number: 3, emoji: '🦋');
          return GameInProgress(
            game: testGame,
            currentQuestion: question,
            currentQuestionIndex: 1,
            correctAnswers: 1,
            totalQuestions: 3,
            score: 10,
          );
        },
        act: (bloc) => bloc.add(RestartGame()),
        expect: () => [
          isA<GameInProgress>()
            .having((s) => s.game, 'game', testGame)
            .having((s) => s.currentQuestionIndex, 'currentQuestionIndex', 0)
            .having((s) => s.correctAnswers, 'correctAnswers', 0)
            .having((s) => s.score, 'score', 0),
        ],
      );
    });
  });
}
