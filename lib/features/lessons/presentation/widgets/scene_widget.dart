import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'flying_butterflies.dart';
import 'playful_monkeys.dart';
import 'singing_birds.dart';
import 'slow_turtles.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Персонаж
        if (widget.scene.character != null) ...[
          _buildCharacter(widget.scene.character!),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Анимированные животные (если указана анимация и это НЕ вопрос)
        if (widget.scene.animation != null && !widget.scene.isQuestion) ...[
          SizedBox(
            height: 200,
            child: _buildAnimationWidget(widget.scene.animation!),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
        ],

        // Животные (с анимацией или статичные)
        // Скрываем статичных животных, если есть фоновая анимация и это НЕ вопрос
        if (animalsToShow != null && animalsToShow.isNotEmpty) ...[
          if (!(widget.scene.animation != null && !widget.scene.isQuestion)) ...[
            _buildAnimals(
              animalsToShow,
              animated: !widget.scene.isQuestion && !widget.scene.waitForAnswer,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        ],

        // Диалог
        if (widget.scene.dialogue != null) ...[
          _buildDialogue(context, widget.scene.dialogue!),
        ],
      ],
    );
  }

  Widget _buildCharacter(String character) {
    // Простой emoji персонаж
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingLarge + 2,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
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

  Widget _buildAnimationWidget(String animation) {
    switch (animation) {
      case 'flying_butterflies':
        return const FlyingButterflies(butterflyCount: 8);
      case 'playful_monkeys':
        return const PlayfulMonkeys(monkeyCount: 4);
      case 'singing_birds':
        return const SingingBirds(birdCount: 2);
      case 'slow_turtles':
        return const SlowTurtles(turtleCount: 5);
      default:
        return const SizedBox.shrink();
    }
  }
}
