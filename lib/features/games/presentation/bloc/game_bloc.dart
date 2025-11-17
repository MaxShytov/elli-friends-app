import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/game.dart';

// Events
abstract class GameEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartGame extends GameEvent {
  final Game game;
  StartGame(this.game);

  @override
  List<Object> get props => [game];
}

class GenerateQuestion extends GameEvent {}

class AnswerQuestion extends GameEvent {
  final int answer;
  AnswerQuestion(this.answer);

  @override
  List<Object> get props => [answer];
}

class NextQuestion extends GameEvent {}

class RestartGame extends GameEvent {}

// States
abstract class GameState extends Equatable {
  @override
  List<Object> get props => [];
}

class GameInitial extends GameState {}

class GameInProgress extends GameState {
  final Game game;
  final GameQuestion currentQuestion;
  final int currentQuestionIndex;
  final int correctAnswers;
  final int totalQuestions;
  final int score;

  GameInProgress({
    required this.game,
    required this.currentQuestion,
    required this.currentQuestionIndex,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
  });

  GameInProgress copyWith({
    Game? game,
    GameQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? correctAnswers,
    int? totalQuestions,
    int? score,
  }) {
    return GameInProgress(
      game: game ?? this.game,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
    );
  }

  @override
  List<Object> get props => [
    game, currentQuestion, currentQuestionIndex,
    correctAnswers, totalQuestions, score,
  ];
}

class GameAnswered extends GameState {
  final bool isCorrect;
  final int correctAnswer;

  GameAnswered({
    required this.isCorrect,
    required this.correctAnswer,
  });

  @override
  List<Object> get props => [isCorrect, correctAnswer];
}

class GameCompleted extends GameState {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int stars;

  GameCompleted({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.stars,
  });

  @override
  List<Object> get props => [score, correctAnswers, totalQuestions, stars];
}

// BLoC
class GameBloc extends Bloc<GameEvent, GameState> {
  final Random _random = Random();

  GameBloc() : super(GameInitial()) {
    on<StartGame>(_onStartGame);
    on<GenerateQuestion>(_onGenerateQuestion);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<RestartGame>(_onRestartGame);
  }

  void _onStartGame(StartGame event, Emitter<GameState> emit) {
    final question = _generateQuestion(event.game);

    emit(GameInProgress(
      game: event.game,
      currentQuestion: question,
      currentQuestionIndex: 0,
      correctAnswers: 0,
      totalQuestions: event.game.config.questionsCount,
      score: 0,
    ));
  }

  void _onGenerateQuestion(GenerateQuestion event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final current = state as GameInProgress;
      final question = _generateQuestion(current.game);

      emit(current.copyWith(currentQuestion: question));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final current = state as GameInProgress;
      final isCorrect = event.answer == current.currentQuestion.number;

      emit(GameAnswered(
        isCorrect: isCorrect,
        correctAnswer: current.currentQuestion.number,
      ));

      // Обновляем счёт
      final newCorrectAnswers = isCorrect
        ? current.correctAnswers + 1
        : current.correctAnswers;
      final newScore = isCorrect ? current.score + 10 : current.score;

      emit(current.copyWith(
        correctAnswers: newCorrectAnswers,
        score: newScore,
      ));
    }
  }

  void _onNextQuestion(NextQuestion event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final current = state as GameInProgress;
      final nextIndex = current.currentQuestionIndex + 1;

      if (nextIndex >= current.totalQuestions) {
        // Игра завершена
        final stars = _calculateStars(
          current.correctAnswers,
          current.totalQuestions,
        );

        emit(GameCompleted(
          score: current.score,
          correctAnswers: current.correctAnswers,
          totalQuestions: current.totalQuestions,
          stars: stars,
        ));
      } else {
        // Следующий вопрос
        final question = _generateQuestion(current.game);

        emit(current.copyWith(
          currentQuestion: question,
          currentQuestionIndex: nextIndex,
        ));
      }
    }
  }

  void _onRestartGame(RestartGame event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final current = state as GameInProgress;
      add(StartGame(current.game));
    }
  }

  GameQuestion _generateQuestion(Game game) {
    final number = _random.nextInt(
      game.config.maxNumber - game.config.minNumber + 1,
    ) + game.config.minNumber;

    final emojis = ['🦋', '🐒', '🐦', '🐢', '🐸'];
    final emoji = emojis[_random.nextInt(emojis.length)];

    return GameQuestion(number: number, emoji: emoji);
  }

  int _calculateStars(int correct, int total) {
    if (total == 0) return 0;

    final percentage = (correct / total) * 100;

    if (percentage >= 90) return 3;
    if (percentage >= 70) return 2;
    if (percentage >= 50) return 1;
    return 0;
  }
}
