import 'package:equatable/equatable.dart';

import '../../../lessons/data/models/lesson_model.dart';
import '../../../lessons/domain/entities/animation_effect.dart';

/// Base class for all editor states
abstract class EditorState extends Equatable {
  const EditorState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class EditorInitial extends EditorState {
  const EditorInitial();
}

/// Loading state while fetching data
class EditorLoading extends EditorState {
  const EditorLoading();
}

/// State showing list of all lessons available for editing
class EditorLessonsList extends EditorState {
  final List<LessonModel> lessons;

  const EditorLessonsList(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

/// State when a lesson is loaded and ready for editing
class EditorLessonLoaded extends EditorState {
  final LessonModel lesson;
  final List<EditableScene> editableScenes;
  final int? selectedSceneIndex;
  final bool hasUnsavedChanges;
  final bool isSaving;

  const EditorLessonLoaded({
    required this.lesson,
    required this.editableScenes,
    this.selectedSceneIndex,
    this.hasUnsavedChanges = false,
    this.isSaving = false,
  });

  EditorLessonLoaded copyWith({
    LessonModel? lesson,
    List<EditableScene>? editableScenes,
    int? selectedSceneIndex,
    bool? clearSelectedScene,
    bool? hasUnsavedChanges,
    bool? isSaving,
  }) {
    return EditorLessonLoaded(
      lesson: lesson ?? this.lesson,
      editableScenes: editableScenes ?? this.editableScenes,
      selectedSceneIndex: clearSelectedScene == true
          ? null
          : (selectedSceneIndex ?? this.selectedSceneIndex),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        editableScenes,
        selectedSceneIndex,
        hasUnsavedChanges,
        isSaving,
      ];
}

/// State while translating
class EditorTranslating extends EditorState {
  final EditorLessonLoaded previousState;
  final int sceneIndex;
  final String sourceLanguage;

  const EditorTranslating({
    required this.previousState,
    required this.sceneIndex,
    required this.sourceLanguage,
  });

  @override
  List<Object?> get props => [previousState, sceneIndex, sourceLanguage];
}

/// Error state
class EditorError extends EditorState {
  final String message;
  final EditorState? previousState;

  const EditorError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Editable scene wrapper with localized dialogue support
class EditableScene extends Equatable {
  final int? databaseId; // null for new scenes
  final String? character;
  final String? animation;
  final String? emotion;
  final String? secondCharacter;
  final String? secondAnimation;
  final String? secondEmotion;
  final Map<String, String> dialogues; // All localized dialogues
  final Map<String, String> buttonTitles; // All localized button titles
  final int? duration;
  final String? tone;
  final String? transitionType;
  final bool isQuestion;
  final bool isPause;
  final int? correctAnswer;
  final bool waitForAnswer;
  final bool showPreviousAnimals;
  final List<AnimalModel>? animals;
  final bool isModified;

  // Новые поля для анимационных эффектов персонажей
  final AnimationEffect? characterEntranceEffect;
  final AnimationEffect? characterExitEffect;
  final AnimationEffect? secondCharacterEntranceEffect;
  final AnimationEffect? secondCharacterExitEffect;

  // Новые поля для фона и звука
  final String? background;
  final String? ambientSound;
  final double? ambientVolume;

  const EditableScene({
    this.databaseId,
    this.character,
    this.animation,
    this.emotion,
    this.secondCharacter,
    this.secondAnimation,
    this.secondEmotion,
    this.dialogues = const {},
    this.buttonTitles = const {},
    this.duration,
    this.tone,
    this.transitionType,
    this.isQuestion = false,
    this.isPause = false,
    this.correctAnswer,
    this.waitForAnswer = false,
    this.showPreviousAnimals = false,
    this.animals,
    this.isModified = false,
    this.characterEntranceEffect,
    this.characterExitEffect,
    this.secondCharacterEntranceEffect,
    this.secondCharacterExitEffect,
    this.background,
    this.ambientSound,
    this.ambientVolume,
  });

  /// Create EditableScene from SceneModel
  factory EditableScene.fromSceneModel(SceneModel scene, {int? databaseId}) {
    return EditableScene(
      databaseId: databaseId,
      character: scene.character,
      animation: scene.animation,
      emotion: scene.emotion,
      secondCharacter: scene.secondCharacter,
      secondAnimation: scene.secondAnimation,
      secondEmotion: scene.secondEmotion,
      dialogues: scene.dialogue != null ? {'en': scene.dialogue!} : {},
      buttonTitles: scene.buttonTitle != null ? {'en': scene.buttonTitle!} : {},
      duration: scene.duration,
      tone: scene.tone,
      transitionType: scene.transitionType,
      isQuestion: scene.isQuestion,
      isPause: scene.isPause,
      correctAnswer: scene.correctAnswer,
      waitForAnswer: scene.waitForAnswer,
      showPreviousAnimals: scene.showPreviousAnimals,
      animals: scene.animals?.map((a) => a as AnimalModel).toList(),
      characterEntranceEffect: scene.characterEntranceEffect,
      characterExitEffect: scene.characterExitEffect,
      secondCharacterEntranceEffect: scene.secondCharacterEntranceEffect,
      secondCharacterExitEffect: scene.secondCharacterExitEffect,
      background: scene.background,
      ambientSound: scene.ambientSound,
      ambientVolume: scene.ambientVolume,
    );
  }

  /// Create a new empty scene
  factory EditableScene.empty() {
    return const EditableScene(
      character: 'orson',
      animation: 'anim_idle',
      emotion: 'Happy',
      transitionType: 'auto_tts',
      dialogues: {'en': ''},
      isModified: true,
    );
  }

  /// Convert to SceneModel for a specific locale
  SceneModel toSceneModel({String locale = 'en'}) {
    return SceneModel(
      character: character,
      animation: animation,
      emotion: emotion,
      secondCharacter: secondCharacter,
      secondAnimation: secondAnimation,
      secondEmotion: secondEmotion,
      dialogue: dialogues[locale] ?? dialogues['en'],
      buttonTitle: buttonTitles[locale] ?? buttonTitles['en'],
      duration: duration,
      tone: tone,
      transitionType: transitionType,
      isQuestion: isQuestion,
      isPause: isPause,
      correctAnswer: correctAnswer,
      waitForAnswer: waitForAnswer,
      showPreviousAnimals: showPreviousAnimals,
      animals: animals,
      characterEntranceEffect: characterEntranceEffect,
      characterExitEffect: characterExitEffect,
      secondCharacterEntranceEffect: secondCharacterEntranceEffect,
      secondCharacterExitEffect: secondCharacterExitEffect,
      background: background,
      ambientSound: ambientSound,
      ambientVolume: ambientVolume,
    );
  }

  /// Get all dialogues as JSON-encodable map
  Map<String, String> get allDialogues => dialogues;

  /// Get all button titles as JSON-encodable map
  Map<String, String> get allButtonTitles => buttonTitles;

  EditableScene copyWith({
    int? databaseId,
    String? character,
    String? animation,
    String? emotion,
    String? secondCharacter,
    String? secondAnimation,
    String? secondEmotion,
    Map<String, String>? dialogues,
    Map<String, String>? buttonTitles,
    int? duration,
    String? tone,
    String? transitionType,
    bool? isQuestion,
    bool? isPause,
    int? correctAnswer,
    bool? waitForAnswer,
    bool? showPreviousAnimals,
    List<AnimalModel>? animals,
    bool? isModified,
    bool? clearSecondCharacter,
    bool? clearCorrectAnswer,
    AnimationEffect? characterEntranceEffect,
    AnimationEffect? characterExitEffect,
    AnimationEffect? secondCharacterEntranceEffect,
    AnimationEffect? secondCharacterExitEffect,
    String? background,
    String? ambientSound,
    double? ambientVolume,
  }) {
    return EditableScene(
      databaseId: databaseId ?? this.databaseId,
      character: character ?? this.character,
      animation: animation ?? this.animation,
      emotion: emotion ?? this.emotion,
      secondCharacter: clearSecondCharacter == true
          ? null
          : (secondCharacter ?? this.secondCharacter),
      secondAnimation: clearSecondCharacter == true
          ? null
          : (secondAnimation ?? this.secondAnimation),
      secondEmotion: clearSecondCharacter == true
          ? null
          : (secondEmotion ?? this.secondEmotion),
      dialogues: dialogues ?? this.dialogues,
      buttonTitles: buttonTitles ?? this.buttonTitles,
      duration: duration ?? this.duration,
      tone: tone ?? this.tone,
      transitionType: transitionType ?? this.transitionType,
      isQuestion: isQuestion ?? this.isQuestion,
      isPause: isPause ?? this.isPause,
      correctAnswer: clearCorrectAnswer == true
          ? null
          : (correctAnswer ?? this.correctAnswer),
      waitForAnswer: waitForAnswer ?? this.waitForAnswer,
      showPreviousAnimals: showPreviousAnimals ?? this.showPreviousAnimals,
      animals: animals ?? this.animals,
      isModified: isModified ?? true,
      characterEntranceEffect: characterEntranceEffect ?? this.characterEntranceEffect,
      characterExitEffect: characterExitEffect ?? this.characterExitEffect,
      secondCharacterEntranceEffect: secondCharacterEntranceEffect ?? this.secondCharacterEntranceEffect,
      secondCharacterExitEffect: secondCharacterExitEffect ?? this.secondCharacterExitEffect,
      background: background ?? this.background,
      ambientSound: ambientSound ?? this.ambientSound,
      ambientVolume: ambientVolume ?? this.ambientVolume,
    );
  }

  /// Get dialogue for a specific language
  String getDialogue(String languageCode) {
    return dialogues[languageCode] ?? dialogues['en'] ?? '';
  }

  @override
  List<Object?> get props => [
        databaseId,
        character,
        animation,
        emotion,
        secondCharacter,
        secondAnimation,
        secondEmotion,
        dialogues,
        buttonTitles,
        duration,
        tone,
        transitionType,
        isQuestion,
        isPause,
        correctAnswer,
        waitForAnswer,
        showPreviousAnimals,
        animals,
        isModified,
        characterEntranceEffect,
        characterExitEffect,
        secondCharacterEntranceEffect,
        secondCharacterExitEffect,
        background,
        ambientSound,
        ambientVolume,
      ];
}
