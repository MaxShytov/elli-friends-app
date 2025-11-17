import 'package:equatable/equatable.dart';

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
  final String? animation;

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
  ];
}

class Animal extends Equatable {
  final String type;
  final String emoji;
  final int count;

  const Animal({
    required this.type,
    required this.emoji,
    required this.count,
  });

  @override
  List<Object?> get props => [type, emoji, count];
}
