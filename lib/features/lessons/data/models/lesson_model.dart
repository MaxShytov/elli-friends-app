import '../../domain/entities/lesson.dart';
import '../../domain/entities/animation_effect.dart';

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

  factory LessonModel.fromJson(Map<String, dynamic> json, {String locale = 'en'}) {
    // Helper function to extract localized string
    String getLocalizedString(dynamic value, String locale) {
      if (value is String) {
        return value;
      } else if (value is Map) {
        return value[locale] as String? ?? value['en'] as String? ?? '';
      }
      return '';
    }

    return LessonModel(
      id: json['id'] as String,
      title: getLocalizedString(json['title'], locale),
      topic: json['topic'] as String,
      description: getLocalizedString(json['description'], locale),
      difficulty: json['difficulty'] as int,
      scenes: (json['scenes'] as List)
          .map((scene) => SceneModel.fromJson(scene, locale: locale))
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
    super.correctAnswerText,
    super.answerOptions,
    super.waitForAnswer,
    super.showPreviousAnimals,
    super.animation,
    super.emotion,
    super.transitionType,
    super.buttonTitle,
    super.secondCharacter,
    super.secondAnimation,
    super.secondEmotion,
    super.characterEntranceEffect,
    super.characterExitEffect,
    super.secondCharacterEntranceEffect,
    super.secondCharacterExitEffect,
    super.background,
    super.ambientSound,
    super.ambientVolume,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json, {String locale = 'en'}) {
    // Helper function to extract localized string
    String? getLocalizedString(dynamic value, String locale) {
      if (value == null) return null;
      if (value is String) {
        return value;
      } else if (value is Map) {
        return value[locale] as String? ?? value['en'] as String?;
      }
      return null;
    }

    return SceneModel(
      character: json['character'] as String?,
      dialogue: getLocalizedString(json['dialogue'], locale),
      duration: json['duration'] as int?,
      tone: json['tone'] as String?,
      animals: (json['animals'] as List?)
          ?.map((animal) => AnimalModel.fromJson(animal))
          .toList(),
      isQuestion: json['isQuestion'] as bool? ?? false,
      isPause: json['isPause'] as bool? ?? false,
      correctAnswer: json['correctAnswer'] as int?,
      correctAnswerText: getLocalizedString(json['correctAnswerText'], locale),
      answerOptions: (json['answerOptions'] as List?)
          ?.map((opt) => AnswerOptionModel.fromJson(opt, locale: locale))
          .toList(),
      waitForAnswer: json['waitForAnswer'] as bool? ?? false,
      showPreviousAnimals: json['showPreviousAnimals'] as bool? ?? false,
      animation: json['animation'] as String?,
      emotion: json['emotion'] as String?,
      transitionType: json['transitionType'] as String?,
      buttonTitle: getLocalizedString(json['buttonTitle'], locale),
      secondCharacter: json['secondCharacter'] as String?,
      secondAnimation: json['secondAnimation'] as String?,
      secondEmotion: json['secondEmotion'] as String?,
      characterEntranceEffect: json['characterEntranceEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['characterEntranceEffect'],
              orElse: () => AnimationEffect.appear,
            )
          : null,
      characterExitEffect: json['characterExitEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['characterExitEffect'],
              orElse: () => AnimationEffect.fadeOut,
            )
          : null,
      secondCharacterEntranceEffect: json['secondCharacterEntranceEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['secondCharacterEntranceEffect'],
              orElse: () => AnimationEffect.appear,
            )
          : null,
      secondCharacterExitEffect: json['secondCharacterExitEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['secondCharacterExitEffect'],
              orElse: () => AnimationEffect.fadeOut,
            )
          : null,
      background: json['background'] as String?,
      ambientSound: json['ambientSound'] as String?,
      ambientVolume: json['ambientVolume'] as double?,
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
      if (correctAnswerText != null) 'correctAnswerText': correctAnswerText,
      if (answerOptions != null) 'answerOptions': answerOptions!.map((o) => (o as AnswerOptionModel).toJson()).toList(),
      'waitForAnswer': waitForAnswer,
      'showPreviousAnimals': showPreviousAnimals,
      'animation': animation,
      'emotion': emotion,
      'transitionType': transitionType,
      'buttonTitle': buttonTitle,
      'secondCharacter': secondCharacter,
      'secondAnimation': secondAnimation,
      'secondEmotion': secondEmotion,
      if (characterEntranceEffect != null) 'characterEntranceEffect': characterEntranceEffect!.name,
      if (characterExitEffect != null) 'characterExitEffect': characterExitEffect!.name,
      if (secondCharacterEntranceEffect != null) 'secondCharacterEntranceEffect': secondCharacterEntranceEffect!.name,
      if (secondCharacterExitEffect != null) 'secondCharacterExitEffect': secondCharacterExitEffect!.name,
      if (background != null) 'background': background,
      if (ambientSound != null) 'ambientSound': ambientSound,
      if (ambientVolume != null) 'ambientVolume': ambientVolume,
    };
  }
}

class AnimalModel extends Animal {
  const AnimalModel({
    required super.type,
    required super.emoji,
    required super.count,
    super.entranceEffect,
    super.activeEffect,
    super.exitEffect,
    super.positionX,
    super.positionY,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      type: json['type'] as String,
      emoji: json['emoji'] as String,
      count: json['count'] as int,
      entranceEffect: json['entranceEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['entranceEffect'],
              orElse: () => AnimationEffect.appear,
            )
          : null,
      activeEffect: json['activeEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['activeEffect'],
              orElse: () => AnimationEffect.idleBobbing,
            )
          : null,
      exitEffect: json['exitEffect'] != null
          ? AnimationEffect.values.firstWhere(
              (e) => e.name == json['exitEffect'],
              orElse: () => AnimationEffect.fadeOut,
            )
          : null,
      positionX: json['positionX'] as double?,
      positionY: json['positionY'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'emoji': emoji,
      'count': count,
      if (entranceEffect != null) 'entranceEffect': entranceEffect!.name,
      if (activeEffect != null) 'activeEffect': activeEffect!.name,
      if (exitEffect != null) 'exitEffect': exitEffect!.name,
      if (positionX != null) 'positionX': positionX,
      if (positionY != null) 'positionY': positionY,
    };
  }

  AnimalModel copyWith({
    String? type,
    String? emoji,
    int? count,
    AnimationEffect? entranceEffect,
    AnimationEffect? activeEffect,
    AnimationEffect? exitEffect,
    double? positionX,
    double? positionY,
  }) {
    return AnimalModel(
      type: type ?? this.type,
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      entranceEffect: entranceEffect ?? this.entranceEffect,
      activeEffect: activeEffect ?? this.activeEffect,
      exitEffect: exitEffect ?? this.exitEffect,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
    );
  }
}

class AnswerOptionModel extends AnswerOption {
  const AnswerOptionModel({
    required super.value,
    required super.label,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json, {String locale = 'en'}) {
    String getLocalizedString(dynamic value, String locale) {
      if (value is String) return value;
      if (value is Map) return value[locale] as String? ?? value['en'] as String? ?? '';
      return '';
    }

    return AnswerOptionModel(
      value: json['value'],  // int или String
      label: getLocalizedString(json['label'], locale),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}
