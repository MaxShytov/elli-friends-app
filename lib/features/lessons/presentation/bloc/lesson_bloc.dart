import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/usecases/get_lesson.dart';

// ==================== EVENTS ====================

abstract class LessonEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadLesson extends LessonEvent {
  final String lessonId;
  LoadLesson(this.lessonId);

  @override
  List<Object> get props => [lessonId];
}

class NextScene extends LessonEvent {}

class PreviousScene extends LessonEvent {}

class AnswerQuestion extends LessonEvent {
  final int answer;
  AnswerQuestion(this.answer);

  @override
  List<Object> get props => [answer];
}

class ResetLesson extends LessonEvent {}

class RetryQuestion extends LessonEvent {}

class StartLesson extends LessonEvent {}

// ==================== STATES ====================

abstract class LessonState extends Equatable {
  @override
  List<Object> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonIntro extends LessonState {
  final Lesson lesson;

  LessonIntro({required this.lesson});

  @override
  List<Object> get props => [lesson];
}

class LessonLoaded extends LessonState {
  final Lesson lesson;
  final int currentSceneIndex;
  final bool isPlaying;
  final int stars;
  final int correctAnswers;

  LessonLoaded({
    required this.lesson,
    this.currentSceneIndex = 0,
    this.isPlaying = true,
    this.stars = 0,
    this.correctAnswers = 0,
  });

  Scene get currentScene => lesson.scenes[currentSceneIndex];
  bool get isLastScene => currentSceneIndex >= lesson.scenes.length - 1;

  LessonLoaded copyWith({
    Lesson? lesson,
    int? currentSceneIndex,
    bool? isPlaying,
    int? stars,
    int? correctAnswers,
  }) {
    return LessonLoaded(
      lesson: lesson ?? this.lesson,
      currentSceneIndex: currentSceneIndex ?? this.currentSceneIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      stars: stars ?? this.stars,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }

  @override
  List<Object> get props => [
    lesson, currentSceneIndex, isPlaying, stars, correctAnswers,
  ];
}

class LessonAnswered extends LessonState {
  final bool isCorrect;
  final int selectedAnswer;
  final LessonLoaded loadedState;

  LessonAnswered(this.isCorrect, this.selectedAnswer, this.loadedState);

  @override
  List<Object> get props => [isCorrect, selectedAnswer, loadedState];
}

class LessonCompleted extends LessonState {
  final Lesson lesson;
  final int stars;
  final int correctAnswers;
  final int totalQuestions;

  LessonCompleted({
    required this.lesson,
    required this.stars,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  List<Object> get props => [lesson, stars, correctAnswers, totalQuestions];
}

class LessonError extends LessonState {
  final String message;
  LessonError(this.message);

  @override
  List<Object> get props => [message];
}

// ==================== BLOC ====================

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final GetLesson getLesson;

  LessonBloc({required this.getLesson}) : super(LessonInitial()) {
    on<LoadLesson>(_onLoadLesson);
    on<StartLesson>(_onStartLesson);
    on<NextScene>(_onNextScene);
    on<PreviousScene>(_onPreviousScene);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<ResetLesson>(_onResetLesson);
    on<RetryQuestion>(_onRetryQuestion);
  }

  Future<void> _onLoadLesson(
    LoadLesson event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());

    try {
      final lesson = await getLesson(event.lessonId);
      // Show intro screen first
      emit(LessonIntro(lesson: lesson));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }

  void _onStartLesson(
    StartLesson event,
    Emitter<LessonState> emit,
  ) {
    if (state is LessonIntro) {
      final intro = state as LessonIntro;
      // Start lesson from first scene
      emit(LessonLoaded(lesson: intro.lesson));
    }
  }

  void _onNextScene(
    NextScene event,
    Emitter<LessonState> emit,
  ) {
    if (state is LessonLoaded) {
      final current = state as LessonLoaded;

      if (current.isLastScene) {
        // Урок завершён
        final totalQuestions = current.lesson.scenes
            .where((s) => s.waitForAnswer && s.correctAnswer != null)
            .length;

        final stars = _calculateStars(
          current.correctAnswers,
          totalQuestions,
        );

        emit(LessonCompleted(
          lesson: current.lesson,
          stars: stars,
          correctAnswers: current.correctAnswers,
          totalQuestions: totalQuestions,
        ));
      } else {
        emit(current.copyWith(
          currentSceneIndex: current.currentSceneIndex + 1,
        ));
      }
    } else if (state is LessonAnswered) {
      // Переход к следующей сцене после ответа
      final answered = state as LessonAnswered;
      final current = answered.loadedState;

      if (current.isLastScene) {
        final totalQuestions = current.lesson.scenes
            .where((s) => s.waitForAnswer && s.correctAnswer != null)
            .length;

        final stars = _calculateStars(
          current.correctAnswers,
          totalQuestions,
        );

        emit(LessonCompleted(
          lesson: current.lesson,
          stars: stars,
          correctAnswers: current.correctAnswers,
          totalQuestions: totalQuestions,
        ));
      } else {
        emit(current.copyWith(
          currentSceneIndex: current.currentSceneIndex + 1,
        ));
      }
    }
  }

  void _onPreviousScene(
    PreviousScene event,
    Emitter<LessonState> emit,
  ) {
    if (state is LessonLoaded) {
      final current = state as LessonLoaded;

      if (current.currentSceneIndex > 0) {
        emit(current.copyWith(
          currentSceneIndex: current.currentSceneIndex - 1,
        ));
      }
    } else if (state is LessonAnswered) {
      // Возврат назад из состояния ответа
      final answered = state as LessonAnswered;
      final current = answered.loadedState;

      if (current.currentSceneIndex > 0) {
        emit(current.copyWith(
          currentSceneIndex: current.currentSceneIndex - 1,
        ));
      }
    }
  }

  void _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<LessonState> emit,
  ) {
    if (state is LessonLoaded) {
      final current = state as LessonLoaded;
      final scene = current.currentScene;

      if (scene.waitForAnswer && scene.correctAnswer != null) {
        final isCorrect = event.answer == scene.correctAnswer;

        // Обновляем счётчик правильных ответов
        final updatedState = isCorrect
          ? current.copyWith(correctAnswers: current.correctAnswers + 1)
          : current;

        emit(LessonAnswered(isCorrect, event.answer, updatedState));
      }
    }
  }

  void _onResetLesson(
    ResetLesson event,
    Emitter<LessonState> emit,
  ) {
    if (state is LessonLoaded) {
      final current = state as LessonLoaded;
      emit(current.copyWith(
        currentSceneIndex: 0,
        correctAnswers: 0,
        stars: 0,
      ));
    } else if (state is LessonCompleted) {
      // Перезапускаем урок с начала
      final completed = state as LessonCompleted;
      emit(LessonLoaded(
        lesson: completed.lesson,
        currentSceneIndex: 0,
        correctAnswers: 0,
        stars: 0,
      ));
    }
  }

  void _onRetryQuestion(
    RetryQuestion event,
    Emitter<LessonState> emit,
  ) {
    if (state is LessonAnswered) {
      final answered = state as LessonAnswered;
      // Возвращаем состояние LessonLoaded, чтобы можно было попробовать снова
      emit(answered.loadedState);
    }
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
