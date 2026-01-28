import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/lesson_bloc.dart';
import '../widgets/scene_widget.dart';
import '../widgets/answer_buttons.dart';
import '../widgets/text_answer_buttons.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/wrong_answer_animation.dart';
import '../widgets/lesson_intro_widget.dart';
import '../../data/datasources/lesson_drift_data_source.dart';
import '../../data/datasources/lesson_local_data_source.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../domain/usecases/get_lesson.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/character_repository.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../core/services/api_key_service.dart';
import '../../../../core/services/azure_tts_service.dart';
import '../../../../core/services/hybrid_audio_service.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';

class LessonPage extends StatelessWidget {
  final String lessonId;

  const LessonPage({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    // Primary: Drift database
    final driftDataSource = LessonDriftDataSourceImpl(AppDatabase.instance);
    // Fallback: JSON assets
    final localDataSource = LessonLocalDataSourceImpl();

    final repository = LessonRepositoryImpl(
      driftDataSource: driftDataSource,
      localDataSource: localDataSource,
      languageCode: currentLocale,
    );
    final getLesson = GetLesson(repository);

    return BlocProvider(
      create: (context) => LessonBloc(getLesson: getLesson)..add(LoadLesson(lessonId)),
      child: const LessonView(),
    );
  }
}

class LessonView extends StatefulWidget {
  const LessonView({super.key});

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  final _audioManager = AudioManager();
  bool _audioInitialized = false;
  bool _showConfetti = false;
  bool _showNextButton = false;
  bool _showTryAgain = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_audioInitialized) {
      _initializeAudio();
      _audioInitialized = true;
    }
  }

  Future<void> _initializeAudio() async {
    final locale = Localizations.localeOf(context).languageCode;
    await _audioManager.initialize(languageCode: locale);

    // Setup CharacterRepository for voice profiles
    final characterRepository = CharacterRepository(AppDatabase.instance);
    _audioManager.setCharacterRepository(characterRepository);

    // Setup Azure TTS if API key is available
    AzureTtsService? azureTtsService;
    try {
      final apiKeyService = await ApiKeyService.getInstance();
      if (apiKeyService.hasAzureApiKey()) {
        azureTtsService = AzureTtsService(
          subscriptionKey: apiKeyService.getAzureApiKey()!,
          region: apiKeyService.getAzureRegion(),
        );
        _audioManager.setAzureTtsService(azureTtsService);
        debugPrint('LessonPage: Azure TTS initialized');
      } else {
        debugPrint('LessonPage: Azure TTS key not set, will use bundled audio or system TTS');
      }
    } catch (e) {
      debugPrint('LessonPage: Failed to initialize Azure TTS: $e');
    }

    // Setup HybridAudioService for bundled + cached + generated audio
    final hybridAudioService = HybridAudioService(
      db: AppDatabase.instance,
      characterRepository: characterRepository,
      azureTtsService: azureTtsService,
    );
    _audioManager.setHybridAudioService(hybridAudioService);
    debugPrint('LessonPage: HybridAudioService initialized');

    // Load voice profiles for current language
    await _audioManager.loadVoiceProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.lesson),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<LessonBloc, LessonState>(
        listener: (context, state) {
          if (state is LessonLoaded) {
            // Set current lesson for HybridAudioService
            _audioManager.setCurrentLesson(state.lesson.id);
            _playScene(state.currentScene, state.currentSceneIndex);
            // Сбрасываем флаги при загрузке новой сцены
            setState(() {
              _showNextButton = false;
              _showConfetti = false;
              _showTryAgain = false;
            });

            // Обработка типа перехода
            final scene = state.currentScene;
            final transitionType = scene.transitionType ?? 'button';

            if (transitionType == 'auto_timer' && scene.duration != null) {
              // Автоматический переход через N секунд
              final bloc = context.read<LessonBloc>();
              Future.delayed(Duration(seconds: scene.duration!)).then((_) {
                if (mounted && bloc.state == state) {
                  bloc.add(NextScene());
                }
              });
            } else if (transitionType == 'auto_tts') {
              if (scene.dialogue != null) {
                // Автоматический переход после проговаривания текста
                // Рассчитываем время на основе длины текста и скорости речи
                final wordsCount = scene.dialogue!.split(' ').length;
                final estimatedDuration = (wordsCount * 0.6).ceil(); // ~0.6 сек на слово для детей
                final bloc = context.read<LessonBloc>();
                Future.delayed(Duration(seconds: estimatedDuration)).then((_) {
                  if (mounted && bloc.state == state) {
                    bloc.add(NextScene());
                  }
                });
              } else {
                // Если нет диалога, но transitionType = auto_tts, переходим сразу
                debugPrint('⚠️ Scene with auto_tts but no dialogue, skipping immediately');
                final bloc = context.read<LessonBloc>();
                Future.delayed(const Duration(milliseconds: 500)).then((_) {
                  if (mounted && bloc.state == state) {
                    bloc.add(NextScene());
                  }
                });
              }
            }
            // Для 'button' - ничего не делаем, ждем нажатия кнопки
            // Для 'task' - ничего не делаем, ждем выполнения задания (waitForAnswer)
          } else if (state is LessonAnswered) {
            _playFeedback(state.isCorrect);

            if (state.isCorrect) {
              // Показываем конфетти при правильном ответе
              setState(() {
                _showConfetti = true;
              });

              // Через 3 секунды показываем кнопку "Дальше"
              Future.delayed(const Duration(seconds: 3)).then((_) {
                if (mounted) {
                  setState(() {
                    _showNextButton = true;
                  });
                }
              });
            } else {
              // Через 0.6 секунды показываем сообщение "Попробуй ещё раз"
              Future.delayed(const Duration(milliseconds: 600)).then((_) {
                if (mounted) {
                  setState(() {
                    _showTryAgain = true;
                  });
                }
              });
            }
          } else if (state is LessonCompleted) {
            _showCompletionDialog(context, state);
          }
        },
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is LessonError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.incorrect,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.lessonLoadError,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is LessonIntro) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.lesson),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ),
              body: LessonIntroWidget(
                lesson: state.lesson,
                onStart: () {
                  context.read<LessonBloc>().add(StartLesson());
                },
              ),
            );
          }

          if (state is LessonLoaded || state is LessonAnswered) {
            final loadedState = state is LessonLoaded
              ? state
              : (state as LessonAnswered).loadedState;
            final scene = loadedState.currentScene;

            return Stack(
              fit: StackFit.expand,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      children: [
                        // Счетчик шагов
                        Text(
                          '${loadedState.currentSceneIndex + 1} / ${loadedState.lesson.scenes.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        // Прогресс
                        LinearProgressIndicator(
                          value: (loadedState.currentSceneIndex + 1) /
                                 loadedState.lesson.scenes.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.correct),
                          minHeight: 8,
                        ),

                        const SizedBox(height: AppDimensions.paddingLarge),

                        // Сцена
                        Expanded(
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: SceneWidget(
                                scene: scene,
                              ),
                            ),
                          ),
                        ),

                        // Обратная связь на ответ
                        if (state is LessonAnswered) ...[
                          const SizedBox(height: AppDimensions.paddingLarge),
                          _buildAnswerFeedback(state.isCorrect),
                        ],

                        // Кнопки ответа (если это вопрос)
                        if (scene.waitForAnswer) ...[
                          const SizedBox(height: AppDimensions.paddingLarge),
                          // Текстовые варианты (если есть answerOptions)
                          if (scene.answerOptions != null && scene.answerOptions!.isNotEmpty)
                            TextAnswerButtons(
                              options: scene.answerOptions!,
                              onAnswer: (answer) {
                                context.read<LessonBloc>().add(
                                  AnswerQuestion(answer),
                                );
                              },
                              selectedAnswer: state is LessonAnswered
                                ? state.selectedAnswer
                                : null,
                              correctAnswer: state is LessonAnswered
                                ? scene.correctAnswerText
                                : null,
                            )
                          // Числовые кнопки (если нет answerOptions, но есть correctAnswer)
                          else if (scene.correctAnswer != null)
                            AnswerButtons(
                              maxNumber: 5,
                              onAnswer: (answer) {
                                context.read<LessonBloc>().add(
                                  AnswerQuestion(answer),
                                );
                              },
                              selectedAnswer: state is LessonAnswered
                                ? state.selectedAnswer
                                : null,
                              correctAnswer: state is LessonAnswered
                                ? scene.correctAnswer
                                : null,
                            ),
                        ],

                        // Навигация
                        if (state is LessonLoaded) ...[
                          const SizedBox(height: AppDimensions.paddingLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Кнопка "Назад" (показывается, если не на первой сцене)
                              if (loadedState.currentSceneIndex > 0) ...[
                                OutlinedButton(
                                  onPressed: () {
                                    context.read<LessonBloc>().add(PreviousScene());
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary, width: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.back,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingMedium),
                              ],
                              // Кнопка "Дальше"
                              ElevatedButton(
                                onPressed: () {
                                  context.read<LessonBloc>().add(NextScene());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  scene.buttonTitle ?? AppLocalizations.of(context)!.next,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Кнопки "Назад" и "Дальше" после правильного ответа
                        if (state is LessonAnswered && _showNextButton) ...[
                          const SizedBox(height: AppDimensions.paddingLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Кнопка "Назад" (показывается, если не на первой сцене)
                              if (loadedState.currentSceneIndex > 0) ...[
                                OutlinedButton(
                                  onPressed: () {
                                    // Сбрасываем флаги при возврате назад
                                    setState(() {
                                      _showConfetti = false;
                                      _showNextButton = false;
                                    });
                                    context.read<LessonBloc>().add(PreviousScene());
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary, width: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.back,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingMedium),
                              ],
                              // Кнопка "Дальше"
                              ElevatedButton(
                                onPressed: () {
                                  context.read<LessonBloc>().add(NextScene());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 20,
                                  ),
                                ),
                                child: Text(
                                  scene.buttonTitle ?? AppLocalizations.of(context)!.next,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Слой конфетти поверх всего
                if (_showConfetti)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ConfettiCelebration(
                        duration: const Duration(hours: 1), // Очень долго, пока не остановим вручную
                        onComplete: () {
                          // Не останавливаем автоматически
                        },
                      ),
                    ),
                  ),

                // Сообщение "Попробуй ещё раз" при неправильном ответе
                if (_showTryAgain)
                  Positioned.fill(
                    child: Center(
                      child: TryAgainMessage(
                        onTryAgain: () {
                          // Скрываем сообщение и возвращаемся в состояние LessonLoaded
                          setState(() {
                            _showTryAgain = false;
                          });
                          context.read<LessonBloc>().add(RetryQuestion());
                        },
                        onSkip: () {
                          // Скрываем сообщение и переходим к следующей сцене
                          setState(() {
                            _showTryAgain = false;
                          });
                          context.read<LessonBloc>().add(NextScene());
                        },
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAnswerFeedback(bool isCorrect) {
    final responsive = ResponsiveHelper(context);

    return Container(
      padding: EdgeInsets.all(responsive.isTablet ? 20.0 : 16.0),
      constraints: BoxConstraints(maxWidth: responsive.maxDialogueWidth),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.correct : AppColors.incorrect,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: responsive.isTablet ? 40.0 : 32.0,
          ),
          const SizedBox(width: 12),
          Text(
            isCorrect
              ? AppLocalizations.of(context)!.correct
              : AppLocalizations.of(context)!.tryAgain,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.isTablet ? 24.0 : 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playScene(scene, int sceneIndex) async {
    if (scene.dialogue != null && scene.character != null) {
      await _audioManager.speakDialogue(
        scene.dialogue!,
        character: scene.character!,
        sceneId: sceneIndex,
        tone: scene.tone,
      );
    }
  }

  Future<void> _playFeedback(bool isCorrect) async {
    if (isCorrect) {
      await _audioManager.playSfx(SoundEffect.wow);
    } else {
      await _audioManager.playSfx(SoundEffect.wrong);
    }
  }

  void _showCompletionDialog(BuildContext context, LessonCompleted state) {
    final responsive = ResponsiveHelper(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: responsive.isTablet ? 100 : 40,
          vertical: 24,
        ),
        title: Row(
          children: [
            const Text('🎉 '),
            Text(AppLocalizations.of(context)!.excellent),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.maxDialogueWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.youEarnedStars(state.stars),
                style: TextStyle(fontSize: responsive.isTablet ? 22.0 : 18.0),
              ),
              const SizedBox(height: 16),
              Text(
                '${state.correctAnswers} ${AppLocalizations.of(context)!.outOf} ${state.totalQuestions} ${AppLocalizations.of(context)!.correct}',
                style: TextStyle(fontSize: responsive.isTablet ? 20.0 : 16.0),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Text(
                    index < state.stars ? '⭐' : '☆',
                    style: TextStyle(fontSize: responsive.isTablet ? 48.0 : 32.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Закрываем диалог
              context.pop(); // Возвращаемся на home
            },
            child: Text(AppLocalizations.of(context)!.done),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Закрываем диалог
              context.read<LessonBloc>().add(ResetLesson());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.again),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioManager.stopSpeaking();
    super.dispose();
  }
}
