import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/api_key_service.dart';
import '../../../../core/services/translation_service.dart';
import '../../../lessons/data/datasources/lesson_drift_data_source.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import '../widgets/scene_list_widget.dart';
import '../widgets/scene_editor_dialog.dart';
import '../widgets/lesson_timeline_view.dart';

/// Page for editing a specific lesson
class LessonEditorPage extends StatefulWidget {
  final String lessonId;

  const LessonEditorPage({super.key, required this.lessonId});

  @override
  State<LessonEditorPage> createState() => _LessonEditorPageState();
}

class _LessonEditorPageState extends State<LessonEditorPage> {
  EditorBloc? _bloc;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
  }

  Future<void> _initializeBloc() async {
    final apiKeyService = await ApiKeyService.getInstance();
    final apiKey = apiKeyService.getClaudeApiKey();

    TranslationService? translationService;
    if (apiKey != null && apiKey.isNotEmpty) {
      translationService = ClaudeTranslationService(apiKey: apiKey);
    }

    _bloc = EditorBloc(
      dataSource: LessonDriftDataSourceImpl(AppDatabase.instance),
      translationService: translationService,
    )..add(LoadLessonForEditing(widget.lessonId));

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _bloc == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _bloc!,
      child: const _LessonEditorPageContent(),
    );
  }
}

class _LessonEditorPageContent extends StatelessWidget {
  const _LessonEditorPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditorBloc, EditorState>(
      listener: (context, state) {
        if (state is EditorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.incorrect,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is EditorLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is EditorLessonLoaded) {
          return _LessonEditorScaffold(state: state);
        }

        if (state is EditorTranslating) {
          return _LessonEditorScaffold(
            state: state.previousState,
            isTranslating: true,
          );
        }

        if (state is EditorError && state.previousState is EditorLessonLoaded) {
          return _LessonEditorScaffold(
            state: state.previousState as EditorLessonLoaded,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.incorrect),
                const SizedBox(height: 16),
                Text(state is EditorError ? state.message : 'Unknown error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LessonEditorScaffold extends StatelessWidget {
  final EditorLessonLoaded state;
  final bool isTranslating;

  const _LessonEditorScaffold({
    required this.state,
    this.isTranslating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.lesson.title,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          // Preview button (disabled if unsaved changes)
          if (state.hasUnsavedChanges)
            // Unsaved badge overlaying Preview
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Unsaved',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () {
                // TODO: Implement preview functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preview coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline, color: Colors.white),
              label: const Text('Preview', style: TextStyle(color: Colors.white)),
            ),
          if (state.hasUnsavedChanges) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Discard Changes',
              onPressed: state.isSaving
                  ? null
                  : () => _showDiscardDialog(context),
            ),
            IconButton(
              icon: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Save Changes',
              onPressed: state.isSaving
                  ? null
                  : () {
                      context.read<EditorBloc>().add(const SaveChanges());
                    },
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Timeline View
              LessonTimelineView(
                scenes: state.editableScenes,
                selectedSceneIndex: state.selectedSceneIndex,
                onSceneSelected: (index) => _showSceneEditor(context, index),
                onSceneReordered: (oldIndex, newIndex) {
                  context.read<EditorBloc>().add(ReorderScenes(
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                  ));
                },
                onAddSceneAt: (position) {
                  context.read<EditorBloc>().add(AddScene(position: position));
                },
                hasUnsavedChanges: state.hasUnsavedChanges,
              ),
              const Divider(height: 1),
              // Scene list
              Expanded(
                child: SceneListWidget(
                  scenes: state.editableScenes,
                  onSceneTap: (index) => _showSceneEditor(context, index),
                  onReorder: (oldIndex, newIndex) {
                    context.read<EditorBloc>().add(ReorderScenes(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    ));
                  },
                  onDelete: (index) => _showDeleteConfirmation(context, index),
                  onDuplicate: (index) {
                    context.read<EditorBloc>().add(DuplicateScene(index));
                  },
                ),
              ),
            ],
          ),
          // Translation overlay
          if (isTranslating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Translating...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSceneEditor(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<EditorBloc>(),
        child: SceneEditorDialog(
          sceneIndex: index,
          scene: state.editableScenes[index],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Scene'),
        content: Text(
          'Are you sure you want to delete scene ${index + 1}?\n\n'
          '"${state.editableScenes[index].getDialogue('en').take(50)}..."',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<EditorBloc>().add(DeleteScene(index));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.incorrect,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard Changes'),
        content: const Text(
          'Are you sure you want to discard all unsaved changes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<EditorBloc>().add(const DiscardChanges());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}

extension _StringExtension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
