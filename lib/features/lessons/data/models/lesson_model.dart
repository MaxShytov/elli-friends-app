import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.topic,
    required super.description,
    required super.difficulty,
    required super.scenes,
    super.tags,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      scenes: (json['scenes'] as List)
          .map((scene) => SceneModel.fromJson(scene))
          .toList(),
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'description': description,
      'difficulty': difficulty,
      'scenes': scenes.map((s) => (s as SceneModel).toJson()).toList(),
      'tags': tags,
    };
  }
}

class SceneModel extends Scene {
  const SceneModel({
    super.character,
    super.dialogue,
    super.duration,
    super.tone,
    super.animals,
    super.isQuestion,
    super.isPause,
    super.correctAnswer,
    super.waitForAnswer,
    super.showPreviousAnimals,
    super.animation,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    return SceneModel(
      character: json['character'] as String?,
      dialogue: json['dialogue'] as String?,
      duration: json['duration'] as int?,
      tone: json['tone'] as String?,
      animals: (json['animals'] as List?)
          ?.map((animal) => AnimalModel.fromJson(animal))
          .toList(),
      isQuestion: json['isQuestion'] as bool? ?? false,
      isPause: json['isPause'] as bool? ?? false,
      correctAnswer: json['correctAnswer'] as int?,
      waitForAnswer: json['waitForAnswer'] as bool? ?? false,
      showPreviousAnimals: json['showPreviousAnimals'] as bool? ?? false,
      animation: json['animation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'dialogue': dialogue,
      'duration': duration,
      'tone': tone,
      'animals': animals?.map((a) => (a as AnimalModel).toJson()).toList(),
      'isQuestion': isQuestion,
      'isPause': isPause,
      'correctAnswer': correctAnswer,
      'waitForAnswer': waitForAnswer,
      'showPreviousAnimals': showPreviousAnimals,
      'animation': animation,
    };
  }
}

class AnimalModel extends Animal {
  const AnimalModel({
    required super.type,
    required super.emoji,
    required super.count,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      type: json['type'] as String,
      emoji: json['emoji'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'emoji': emoji,
      'count': count,
    };
  }
}
