import 'package:equatable/equatable.dart';

import '../../../lessons/data/models/lesson_model.dart';

/// Base class for all editor events
abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

/// Load all lessons for editing
class LoadLessonsForEditing extends EditorEvent {
  const LoadLessonsForEditing();
}

/// Load a specific lesson for editing
class LoadLessonForEditing extends EditorEvent {
  final String lessonId;

  const LoadLessonForEditing(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

/// Update scene dialogue text
class UpdateSceneDialogue extends EditorEvent {
  final int sceneIndex;
  final String languageCode;
  final String newText;

  const UpdateSceneDialogue({
    required this.sceneIndex,
    required this.languageCode,
    required this.newText,
  });

  @override
  List<Object?> get props => [sceneIndex, languageCode, newText];
}

/// Update scene character settings
class UpdateSceneCharacter extends EditorEvent {
  final int sceneIndex;
  final String? character;
  final String? animation;
  final String? emotion;

  const UpdateSceneCharacter({
    required this.sceneIndex,
    this.character,
    this.animation,
    this.emotion,
  });

  @override
  List<Object?> get props => [sceneIndex, character, animation, emotion];
}

/// Update second character settings
class UpdateSecondCharacter extends EditorEvent {
  final int sceneIndex;
  final String? character;
  final String? animation;
  final String? emotion;

  const UpdateSecondCharacter({
    required this.sceneIndex,
    this.character,
    this.animation,
    this.emotion,
  });

  @override
  List<Object?> get props => [sceneIndex, character, animation, emotion];
}

/// Update scene settings (duration, tone, transitionType, etc.)
class UpdateSceneSettings extends EditorEvent {
  final int sceneIndex;
  final int? duration;
  final String? tone;
  final String? transitionType;
  final bool? isQuestion;
  final bool? isPause;
  final int? correctAnswer;
  final bool? waitForAnswer;
  final bool? showPreviousAnimals;
  final String? buttonTitle;
  final String? background;
  final String? ambientSound;
  final double? ambientVolume;

  const UpdateSceneSettings({
    required this.sceneIndex,
    this.duration,
    this.tone,
    this.transitionType,
    this.isQuestion,
    this.isPause,
    this.correctAnswer,
    this.waitForAnswer,
    this.showPreviousAnimals,
    this.buttonTitle,
    this.background,
    this.ambientSound,
    this.ambientVolume,
  });

  @override
  List<Object?> get props => [
        sceneIndex,
        duration,
        tone,
        transitionType,
        isQuestion,
        isPause,
        correctAnswer,
        waitForAnswer,
        showPreviousAnimals,
        buttonTitle,
        background,
        ambientSound,
        ambientVolume,
      ];
}

/// Update animals for a scene
class UpdateSceneAnimals extends EditorEvent {
  final int sceneIndex;
  final List<AnimalModel> animals;

  const UpdateSceneAnimals({
    required this.sceneIndex,
    required this.animals,
  });

  @override
  List<Object?> get props => [sceneIndex, animals];
}

/// Add a new scene to the lesson
class AddScene extends EditorEvent {
  final int? position; // null = append at end

  const AddScene({this.position});

  @override
  List<Object?> get props => [position];
}

/// Delete a scene from the lesson
class DeleteScene extends EditorEvent {
  final int sceneIndex;

  const DeleteScene(this.sceneIndex);

  @override
  List<Object?> get props => [sceneIndex];
}

/// Reorder scenes via drag-and-drop
class ReorderScenes extends EditorEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderScenes({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Split a scene at a specific position
class SplitScene extends EditorEvent {
  final int sceneIndex;
  final int splitPosition; // Character position to split dialogue

  const SplitScene({
    required this.sceneIndex,
    required this.splitPosition,
  });

  @override
  List<Object?> get props => [sceneIndex, splitPosition];
}

/// Duplicate a scene
class DuplicateScene extends EditorEvent {
  final int sceneIndex;

  const DuplicateScene(this.sceneIndex);

  @override
  List<Object?> get props => [sceneIndex];
}

/// Translate dialogue to all languages using Claude API
class TranslateDialogue extends EditorEvent {
  final int sceneIndex;
  final String sourceLanguage;

  const TranslateDialogue({
    required this.sceneIndex,
    required this.sourceLanguage,
  });

  @override
  List<Object?> get props => [sceneIndex, sourceLanguage];
}

/// Save all changes to database
class SaveChanges extends EditorEvent {
  const SaveChanges();
}

/// Discard all unsaved changes
class DiscardChanges extends EditorEvent {
  const DiscardChanges();
}
