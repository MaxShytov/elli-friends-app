import 'package:equatable/equatable.dart';
import 'animation_effect.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final String topic;
  final String description;
  final int difficulty;
  final List<Scene> scenes;
  final List<String> tags;

  const Lesson({
    required this.id,
    required this.title,
    required this.topic,
    required this.description,
    required this.difficulty,
    required this.scenes,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [id, title, topic, description, difficulty, scenes, tags];
}

class Scene extends Equatable {
  final String? character;
  final String? dialogue;
  final int? duration;
  final String? tone;
  final List<Animal>? animals;
  final bool isQuestion;
  final bool isPause;
  final int? correctAnswer;
  final bool waitForAnswer;
  final bool showPreviousAnimals;
  final String? animation; // Rive animation trigger (e.g., 'anim_wave', 'anim_happy')
  final String? emotion; // Character emotion (e.g., 'Happy', 'Sad', 'Neutral')
  final String? transitionType; // auto_tts, auto_timer, button, task
  final String? buttonTitle; // Custom button text (e.g., 'Yes', 'Let's go', 'Continue')
  final String? secondCharacter; // Second character name
  final String? secondAnimation; // Second character animation
  final String? secondEmotion; // Second character emotion

  // Новые поля для анимационных эффектов персонажей
  final AnimationEffect? characterEntranceEffect;
  final AnimationEffect? characterExitEffect;
  final AnimationEffect? secondCharacterEntranceEffect;
  final AnimationEffect? secondCharacterExitEffect;

  // Новые поля для фона и звука
  final String? background;  // "jungle_morning", "jungle_evening"
  final String? ambientSound; // "jungle_ambience"
  final double? ambientVolume; // 0.0 - 1.0

  const Scene({
    this.character,
    this.dialogue,
    this.duration,
    this.tone,
    this.animals,
    this.isQuestion = false,
    this.isPause = false,
    this.correctAnswer,
    this.waitForAnswer = false,
    this.showPreviousAnimals = false,
    this.animation,
    this.emotion,
    this.transitionType,
    this.buttonTitle,
    this.secondCharacter,
    this.secondAnimation,
    this.secondEmotion,
    this.characterEntranceEffect,
    this.characterExitEffect,
    this.secondCharacterEntranceEffect,
    this.secondCharacterExitEffect,
    this.background,
    this.ambientSound,
    this.ambientVolume,
  });

  @override
  List<Object?> get props => [
    character,
    dialogue,
    duration,
    tone,
    animals,
    isQuestion,
    isPause,
    correctAnswer,
    waitForAnswer,
    showPreviousAnimals,
    animation,
    emotion,
    transitionType,
    buttonTitle,
    secondCharacter,
    secondAnimation,
    secondEmotion,
    characterEntranceEffect,
    characterExitEffect,
    secondCharacterEntranceEffect,
    secondCharacterExitEffect,
    background,
    ambientSound,
    ambientVolume,
  ];
}

class Animal extends Equatable {
  final String type;
  final String emoji;
  final int count;
  final AnimationEffect? entranceEffect;
  final AnimationEffect? activeEffect;
  final AnimationEffect? exitEffect;
  final double? positionX;  // Позиция X (0.0-1.0, относительно ширины экрана)
  final double? positionY;  // Позиция Y (0.0-1.0, относительно высоты экрана)

  const Animal({
    required this.type,
    required this.emoji,
    required this.count,
    this.entranceEffect,
    this.activeEffect,
    this.exitEffect,
    this.positionX,
    this.positionY,
  });

  @override
  List<Object?> get props => [type, emoji, count, entranceEffect, activeEffect, exitEffect, positionX, positionY];
}
