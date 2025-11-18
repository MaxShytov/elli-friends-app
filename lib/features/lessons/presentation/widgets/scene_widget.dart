import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../../domain/entities/lesson.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget for displaying a lesson scene
class SceneWidget extends StatefulWidget {
  final Scene scene;

  const SceneWidget({
    super.key,
    required this.scene,
  });

  @override
  State<SceneWidget> createState() => _SceneWidgetState();
}

class _SceneWidgetState extends State<SceneWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  // Rive variables
  rive.File? _riveFile;
  rive.RiveWidgetController? _riveController;
  rive.ViewModelInstance? _viewModel;
  rive.ViewModelInstanceEnum? _characterSelectEnum;
  rive.ViewModelInstanceEnum? _faceEmotionEnum;
  bool _riveLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Запускаем анимацию, если есть животные И это НЕ сцена с вопросом
    final hasAnimals = widget.scene.animals != null && widget.scene.animals!.isNotEmpty;
    final isNotQuestion = !widget.scene.isQuestion && !widget.scene.waitForAnswer;
    if (hasAnimals && isNotQuestion) {
      _controller.repeat(reverse: true);
    }

    // Load Rive file if character is specified
    if (widget.scene.character != null) {
      _loadRiveFile();
    }
  }

  Future<void> _loadRiveFile() async {
    try {
      // Dispose old resources before loading new character
      _viewModel?.dispose();
      _riveController?.dispose();

      setState(() {
        _riveLoaded = false;
      });

      _riveFile = await rive.File.asset(
        'assets/animations/responsive_mascots.riv',
        riveFactory: kIsWeb ? rive.Factory.flutter : rive.Factory.rive,
      );

      _riveController = rive.RiveWidgetController(
        _riveFile!,
        stateMachineSelector: rive.StateMachineSelector.byIndex(0),
      );

      // Initialize view model
      _viewModel = _riveController!.dataBind(rive.DataBind.auto());
      if (_viewModel != null) {
        _characterSelectEnum = _viewModel!.enumerator('CharacterSelect');
        _faceEmotionEnum = _viewModel!.enumerator('FaceEmotion');

        // Set character
        final characterName = _getCharacterName(widget.scene.character!);
        if (_characterSelectEnum != null) {
          _characterSelectEnum!.value = characterName;
          debugPrint('✅ Set character to: $characterName');
        }

        // Set emotion
        if (widget.scene.emotion != null && _faceEmotionEnum != null) {
          _faceEmotionEnum!.value = widget.scene.emotion!;
          debugPrint('✅ Set emotion to: ${widget.scene.emotion}');
        }

        // Trigger animation
        if (widget.scene.animation != null) {
          _triggerAnimation(widget.scene.animation!);
        }
      }

      if (mounted) {
        setState(() {
          _riveLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load Rive file: $e');
    }
  }

  void _triggerAnimation(String animationName) {
    if (_viewModel != null) {
      try {
        final triggerProperty = _viewModel!.trigger(animationName);
        if (triggerProperty != null) {
          triggerProperty.trigger();
        }
      } catch (e) {
        debugPrint('❌ Error triggering animation: $e');
      }
    }
  }

  String _getCharacterName(String character) {
    switch (character.toLowerCase()) {
      case 'orson':
      case 'орсон':
        return 'Orson';
      case 'merv':
      case 'мерв':
        return 'Merv';
      default:
        return 'Orson';
    }
  }

  @override
  void didUpdateWidget(SceneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If scene changed, update Rive state
    if (oldWidget.scene != widget.scene) {
      // If character changed, reload Rive file
      if (widget.scene.character != oldWidget.scene.character &&
          widget.scene.character != null) {
        debugPrint('🔄 Character changed from ${oldWidget.scene.character} to ${widget.scene.character}, reloading Rive');
        _loadRiveFile();
      } else {
        // Update emotion if changed
        if (widget.scene.emotion != oldWidget.scene.emotion &&
            widget.scene.emotion != null &&
            _faceEmotionEnum != null) {
          _faceEmotionEnum!.value = widget.scene.emotion!;
          debugPrint('✅ Updated emotion to: ${widget.scene.emotion}');
        }

        // Trigger new animation if specified
        if (widget.scene.animation != null &&
            widget.scene.animation != oldWidget.scene.animation) {
          _triggerAnimation(widget.scene.animation!);
          debugPrint('✅ Triggered animation: ${widget.scene.animation}');
        }
      }

      // Update bounce animation for animals
      final hasAnimals = widget.scene.animals != null && widget.scene.animals!.isNotEmpty;
      final isNotQuestion = !widget.scene.isQuestion && !widget.scene.waitForAnswer;
      if (hasAnimals && isNotQuestion) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _riveController?.dispose();
    _viewModel?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Используем животных из сцены
    final animalsToShow = widget.scene.animals;

    // Если это сцена паузы для ответа без контента, показываем подсказку
    if (widget.scene.isPause && widget.scene.waitForAnswer &&
        widget.scene.character == null && widget.scene.dialogue == null &&
        (animalsToShow == null || animalsToShow.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Text(
            'Выберите правильный ответ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Персонаж
        if (widget.scene.character != null) ...[
          _buildCharacter(widget.scene.character!),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],

        // Животные (с анимацией или статичные)
        // Скрываем статичных животных, если есть фоновая анимация и это НЕ вопрос
        if (animalsToShow != null && animalsToShow.isNotEmpty) ...[
          if (!(widget.scene.animation != null && !widget.scene.isQuestion)) ...[
            _buildAnimals(
              animalsToShow,
              animated: !widget.scene.isQuestion && !widget.scene.waitForAnswer,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ],

        // Диалог
        if (widget.scene.dialogue != null) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildDialogue(context, widget.scene.dialogue!),
        ],
      ],
    );
  }

  Widget _buildCharacter(String character) {
    // Show Rive character if loaded
    if (_riveLoaded && _riveController != null) {
      return SizedBox(
        width: 300,
        height: 300,
        child: rive.RiveWidget(
          controller: _riveController!,
          fit: rive.Fit.contain,
        ),
      );
    }

    // Fallback to emoji while loading
    final emoji = _getCharacterEmoji(character);
    return Container(
      width: AppDimensions.characterSize,
      height: AppDimensions.characterSize,
      decoration: BoxDecoration(
        color: _getCharacterBgColor(character),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  Widget _buildAnimals(List<Animal> animals, {required bool animated}) {
    return Wrap(
      spacing: AppDimensions.paddingMedium,
      runSpacing: AppDimensions.paddingMedium,
      alignment: WrapAlignment.center,
      children: animals.map((animal) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            animal.count,
            (index) => animated
                ? AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_bounceAnimation.value),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            animal.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      animal.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDialogue(BuildContext context, String dialogue) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        dialogue,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getCharacterEmoji(String character) {
    switch (character.toLowerCase()) {
      case 'elli':
      case 'элли':
        return '🐘';
      case 'bono':
      case 'боно':
        return '🐘';
      case 'hippo':
      case 'гиппо':
        return '🦛';
      case 'orson':
      case 'орсон':
        return '🐱';
      case 'merv':
      case 'мерв':
        return '🧙';
      default:
        return '😊';
    }
  }

  Color _getCharacterBgColor(String character) {
    switch (character.toLowerCase()) {
      case 'elli':
      case 'элли':
        return AppColors.elliBg;
      case 'bono':
      case 'боно':
        return AppColors.bonoBg;
      case 'hippo':
      case 'гиппо':
        return AppColors.hippoBg;
      default:
        return AppColors.cardBg;
    }
  }

}
