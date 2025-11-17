import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/game_bloc.dart';
import '../../domain/entities/game.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class GamePage extends StatelessWidget {
  final String gameId;

  const GamePage({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    // Создаём конфигурацию игры (потом загрузим из JSON)
    final game = Game(
      id: gameId,
      title: 'Посчитай животных',
      type: 'counting',
      difficulty: 1,
      config: const GameConfig(
        minNumber: 1,
        maxNumber: 5,
        questionsCount: 5,
      ),
    );

    return BlocProvider(
      create: (context) => GameBloc()..add(StartGame(game)),
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameAnswered) {
            // Автоматически переходим к следующему вопросу
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.read<GameBloc>().add(NextQuestion());
              }
            });
          } else if (state is GameCompleted) {
            _showCompletionDialog(context, state);
          }
        },
        builder: (context, state) {
          if (state is GameInProgress) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    // Прогресс и счёт
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Вопрос ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Счёт: ${state.score}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingXLarge),

                    // Вопрос: Животные
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Сколько животных?',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),

                            const SizedBox(height: AppDimensions.paddingLarge),

                            // Отображаем животных
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                state.currentQuestion.number,
                                (index) => Text(
                                  state.currentQuestion.emoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Кнопки ответа
                    Wrap(
                      spacing: AppDimensions.paddingMedium,
                      runSpacing: AppDimensions.paddingMedium,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        state.game.config.maxNumber,
                        (index) {
                          final number = index + 1;
                          return _AnswerButton(
                            number: number,
                            onTap: () {
                              context.read<GameBloc>().add(
                                AnswerQuestion(number),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GameAnswered) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.isCorrect ? '🎉' : '😊',
                    style: const TextStyle(fontSize: 96),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isCorrect ? 'Правильно!' : 'Попробуй ещё!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (!state.isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Правильный ответ: ${state.correctAnswer}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, GameCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎮 Игра завершена!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Счёт: ${state.score}'),
            const SizedBox(height: 8),
            Text('${state.correctAnswers} из ${state.totalQuestions} правильных'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Text(
                  index < state.stars ? '⭐' : '☆',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Готово'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.read<GameBloc>().add(RestartGame());
            },
            child: const Text('Ещё раз'),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
