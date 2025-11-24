import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/translation_service.dart';
import '../../../lessons/data/datasources/lesson_drift_data_source.dart';
import '../../../lessons/data/models/lesson_model.dart';
import 'editor_event.dart';
import 'editor_state.dart';

/// BLoC for managing lesson editor state
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final LessonDriftDataSource dataSource;
  final TranslationService? translationService;

  EditorBloc({
    required this.dataSource,
    this.translationService,
  }) : super(const EditorInitial()) {
    on<LoadLessonsForEditing>(_onLoadLessonsForEditing);
    on<LoadLessonForEditing>(_onLoadLessonForEditing);
    on<UpdateSceneDialogue>(_onUpdateSceneDialogue);
    on<UpdateSceneCharacter>(_onUpdateSceneCharacter);
    on<UpdateSecondCharacter>(_onUpdateSecondCharacter);
    on<UpdateSceneSettings>(_onUpdateSceneSettings);
    on<UpdateSceneAnimals>(_onUpdateSceneAnimals);
    on<AddScene>(_onAddScene);
    on<DeleteScene>(_onDeleteScene);
    on<ReorderScenes>(_onReorderScenes);
    on<SplitScene>(_onSplitScene);
    on<DuplicateScene>(_onDuplicateScene);
    on<TranslateDialogue>(_onTranslateDialogue);
    on<SaveChanges>(_onSaveChanges);
    on<DiscardChanges>(_onDiscardChanges);
  }

  Future<void> _onLoadLessonsForEditing(
    LoadLessonsForEditing event,
    Emitter<EditorState> emit,
  ) async {
    emit(const EditorLoading());

    try {
      final lessons = await dataSource.getAllLessons();
      emit(EditorLessonsList(lessons));
    } catch (e) {
      emit(EditorError('Failed to load lessons: $e'));
    }
  }

  Future<void> _onLoadLessonForEditing(
    LoadLessonForEditing event,
    Emitter<EditorState> emit,
  ) async {
    emit(const EditorLoading());

    try {
      // Load lesson with all localizations for editing
      final rawData = await dataSource.getLessonWithLocalizations(event.lessonId);
      if (rawData == null) {
        emit(EditorError('Lesson not found: ${event.lessonId}'));
        return;
      }

      // Convert scenes to editable scenes with all localized data
      final editableScenes = rawData.scenes.asMap().entries.map((entry) {
        final rawScene = entry.value;
        return EditableScene(
          databaseId: entry.key,
          character: rawScene.scene.character,
          animation: rawScene.scene.animation,
          emotion: rawScene.scene.emotion,
          secondCharacter: rawScene.scene.secondCharacter,
          secondAnimation: rawScene.scene.secondAnimation,
          secondEmotion: rawScene.scene.secondEmotion,
          dialogues: rawScene.dialogues,
          buttonTitles: rawScene.buttonTitles,
          duration: rawScene.scene.duration,
          tone: rawScene.scene.tone,
          transitionType: rawScene.scene.transitionType,
          isQuestion: rawScene.scene.isQuestion,
          isPause: rawScene.scene.isPause,
          correctAnswer: rawScene.scene.correctAnswer,
          waitForAnswer: rawScene.scene.waitForAnswer,
          showPreviousAnimals: rawScene.scene.showPreviousAnimals,
          animals: rawScene.scene.animals?.map((a) => a as AnimalModel).toList(),
        );
      }).toList();

      emit(EditorLessonLoaded(
        lesson: rawData.lesson,
        editableScenes: editableScenes,
      ));
    } catch (e) {
      emit(EditorError('Failed to load lesson: $e'));
    }
  }

  void _onUpdateSceneDialogue(
    UpdateSceneDialogue event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    final scene = scenes[event.sceneIndex];
    final newDialogues = Map<String, String>.from(scene.dialogues);
    newDialogues[event.languageCode] = event.newText;

    scenes[event.sceneIndex] = scene.copyWith(
      dialogues: newDialogues,
      isModified: true,
    );

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onUpdateSceneCharacter(
    UpdateSceneCharacter event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    final scene = scenes[event.sceneIndex];
    scenes[event.sceneIndex] = scene.copyWith(
      character: event.character,
      animation: event.animation,
      emotion: event.emotion,
      isModified: true,
    );

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onUpdateSecondCharacter(
    UpdateSecondCharacter event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    final scene = scenes[event.sceneIndex];
    final clearSecond = event.character == null &&
        event.animation == null &&
        event.emotion == null;

    scenes[event.sceneIndex] = scene.copyWith(
      secondCharacter: event.character,
      secondAnimation: event.animation,
      secondEmotion: event.emotion,
      clearSecondCharacter: clearSecond,
      isModified: true,
    );

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onUpdateSceneSettings(
    UpdateSceneSettings event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    final scene = scenes[event.sceneIndex];

    // Update button title if provided
    Map<String, String>? newButtonTitles;
    if (event.buttonTitle != null) {
      newButtonTitles = Map<String, String>.from(scene.buttonTitles);
      newButtonTitles['en'] = event.buttonTitle!;
    }

    scenes[event.sceneIndex] = scene.copyWith(
      duration: event.duration,
      tone: event.tone,
      transitionType: event.transitionType,
      isQuestion: event.isQuestion,
      isPause: event.isPause,
      correctAnswer: event.correctAnswer,
      waitForAnswer: event.waitForAnswer,
      showPreviousAnimals: event.showPreviousAnimals,
      buttonTitles: newButtonTitles,
      isModified: true,
    );

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onUpdateSceneAnimals(
    UpdateSceneAnimals event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    scenes[event.sceneIndex] = scenes[event.sceneIndex].copyWith(
      animals: event.animals,
      isModified: true,
    );

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onAddScene(
    AddScene event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    final newScene = EditableScene.empty();

    if (event.position != null && event.position! < scenes.length) {
      scenes.insert(event.position!, newScene);
    } else {
      scenes.add(newScene);
    }

    emit(currentState.copyWith(
      editableScenes: scenes,
      selectedSceneIndex: event.position ?? scenes.length - 1,
      hasUnsavedChanges: true,
    ));
  }

  void _onDeleteScene(
    DeleteScene event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length || scenes.length <= 1) return;

    scenes.removeAt(event.sceneIndex);

    emit(currentState.copyWith(
      editableScenes: scenes,
      clearSelectedScene: true,
      hasUnsavedChanges: true,
    ));
  }

  void _onReorderScenes(
    ReorderScenes event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.oldIndex >= scenes.length || event.newIndex >= scenes.length) {
      return;
    }

    final scene = scenes.removeAt(event.oldIndex);
    scenes.insert(event.newIndex, scene);

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onSplitScene(
    SplitScene event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    final scene = scenes[event.sceneIndex];
    final dialogue = scene.getDialogue('en');

    if (event.splitPosition <= 0 || event.splitPosition >= dialogue.length) {
      return;
    }

    // Split dialogues for all languages
    final firstDialogues = <String, String>{};
    final secondDialogues = <String, String>{};

    for (final entry in scene.dialogues.entries) {
      final text = entry.value;
      if (text.length > event.splitPosition) {
        firstDialogues[entry.key] = text.substring(0, event.splitPosition).trim();
        secondDialogues[entry.key] = text.substring(event.splitPosition).trim();
      } else {
        firstDialogues[entry.key] = text;
        secondDialogues[entry.key] = '';
      }
    }

    // Create two scenes from the split
    final firstScene = scene.copyWith(
      dialogues: firstDialogues,
      isModified: true,
    );

    final secondScene = EditableScene(
      character: scene.character,
      animation: scene.animation,
      emotion: scene.emotion,
      dialogues: secondDialogues,
      transitionType: scene.transitionType,
      isModified: true,
    );

    scenes[event.sceneIndex] = firstScene;
    scenes.insert(event.sceneIndex + 1, secondScene);

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  void _onDuplicateScene(
    DuplicateScene event,
    Emitter<EditorState> emit,
  ) {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    final scenes = List<EditableScene>.from(currentState.editableScenes);
    if (event.sceneIndex >= scenes.length) return;

    final scene = scenes[event.sceneIndex];
    final duplicated = EditableScene(
      character: scene.character,
      animation: scene.animation,
      emotion: scene.emotion,
      secondCharacter: scene.secondCharacter,
      secondAnimation: scene.secondAnimation,
      secondEmotion: scene.secondEmotion,
      dialogues: Map.from(scene.dialogues),
      buttonTitles: Map.from(scene.buttonTitles),
      duration: scene.duration,
      tone: scene.tone,
      transitionType: scene.transitionType,
      isQuestion: scene.isQuestion,
      isPause: scene.isPause,
      correctAnswer: scene.correctAnswer,
      waitForAnswer: scene.waitForAnswer,
      showPreviousAnimals: scene.showPreviousAnimals,
      animals: scene.animals != null ? List.from(scene.animals!) : null,
      isModified: true,
    );

    scenes.insert(event.sceneIndex + 1, duplicated);

    emit(currentState.copyWith(
      editableScenes: scenes,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onTranslateDialogue(
    TranslateDialogue event,
    Emitter<EditorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    debugPrint('[EditorBloc] TranslateDialogue: sceneIndex=${event.sceneIndex}, sourceLang=${event.sourceLanguage}');
    debugPrint('[EditorBloc] translationService is null: ${translationService == null}');

    if (translationService == null) {
      emit(EditorError(
        'Translation service not configured. Please set up API key.',
        previousState: currentState,
      ));
      return;
    }

    final scene = currentState.editableScenes[event.sceneIndex];
    final sourceText = scene.dialogues[event.sourceLanguage] ?? '';

    debugPrint('[EditorBloc] Source text: "$sourceText"');
    debugPrint('[EditorBloc] Current dialogues: ${scene.dialogues}');

    if (sourceText.isEmpty) {
      emit(EditorError(
        'No text to translate in ${event.sourceLanguage}',
        previousState: currentState,
      ));
      return;
    }

    emit(EditorTranslating(
      previousState: currentState,
      sceneIndex: event.sceneIndex,
      sourceLanguage: event.sourceLanguage,
    ));

    try {
      final translations = await translationService!.translateToAllLanguages(
        text: sourceText,
        sourceLanguage: event.sourceLanguage,
      );

      debugPrint('[EditorBloc] Translations received: $translations');

      // Update scene with new translations
      final scenes = List<EditableScene>.from(currentState.editableScenes);
      scenes[event.sceneIndex] = scene.copyWith(
        dialogues: translations,
        isModified: true,
      );

      debugPrint('[EditorBloc] Emitting new state with updated dialogues');

      emit(currentState.copyWith(
        editableScenes: scenes,
        hasUnsavedChanges: true,
      ));
    } catch (e) {
      debugPrint('[EditorBloc] Translation error: $e');
      emit(EditorError(
        'Translation failed: $e',
        previousState: currentState,
      ));
    }
  }

  Future<void> _onSaveChanges(
    SaveChanges event,
    Emitter<EditorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    emit(currentState.copyWith(isSaving: true));

    try {
      // Convert editable scenes back to SceneModels
      final scenes = currentState.editableScenes
          .map((e) => e.toSceneModel())
          .toList();

      // Extract all localizations from editable scenes
      final sceneDialogues = currentState.editableScenes
          .map((e) => e.allDialogues)
          .toList();
      final sceneButtonTitles = currentState.editableScenes
          .map((e) => e.allButtonTitles)
          .toList();

      // Create updated lesson model
      final updatedLesson = LessonModel(
        id: currentState.lesson.id,
        title: currentState.lesson.title,
        topic: currentState.lesson.topic,
        description: currentState.lesson.description,
        difficulty: currentState.lesson.difficulty,
        tags: currentState.lesson.tags,
        scenes: scenes,
      );

      // Save with full localization data
      await dataSource.saveLessonWithLocalizations(
        lesson: updatedLesson,
        sceneDialogues: sceneDialogues,
        sceneButtonTitles: sceneButtonTitles,
      );

      // Mark all scenes as not modified
      final savedScenes = currentState.editableScenes
          .map((e) => e.copyWith(isModified: false))
          .toList();

      emit(currentState.copyWith(
        editableScenes: savedScenes,
        hasUnsavedChanges: false,
        isSaving: false,
      ));
    } catch (e) {
      emit(EditorError(
        'Failed to save changes: $e',
        previousState: currentState.copyWith(isSaving: false),
      ));
    }
  }

  Future<void> _onDiscardChanges(
    DiscardChanges event,
    Emitter<EditorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EditorLessonLoaded) return;

    // Reload the lesson from database
    add(LoadLessonForEditing(currentState.lesson.id));
  }
}
