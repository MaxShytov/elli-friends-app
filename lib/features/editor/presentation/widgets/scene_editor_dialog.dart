import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../lessons/data/models/lesson_model.dart';
import '../../../lessons/domain/entities/animation_effect.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import 'animation_effect_picker.dart';
import 'character_picker.dart';
import 'dialogue_editor.dart';
import 'scene_preview_widget.dart';

/// Dialog for editing a single scene
class SceneEditorDialog extends StatefulWidget {
  final int sceneIndex;
  final EditableScene scene;

  const SceneEditorDialog({
    super.key,
    required this.sceneIndex,
    required this.scene,
  });

  @override
  State<SceneEditorDialog> createState() => _SceneEditorDialogState();
}

class _SceneEditorDialogState extends State<SceneEditorDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Scene ${widget.sceneIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Tab bar
            Container(
              color: Colors.purple.shade100,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.purple.shade300,
                indicatorColor: Colors.purple,
                tabs: const [
                  Tab(icon: Icon(Icons.text_fields), text: 'Dialogue'),
                  Tab(icon: Icon(Icons.person), text: 'Character'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  Tab(icon: Icon(Icons.pets), text: 'Animals'),
                  Tab(icon: Icon(Icons.visibility), text: 'Preview'),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: BlocBuilder<EditorBloc, EditorState>(
                builder: (context, state) {
                  // Get the current scene from state
                  // Handle different state types that may contain scene data
                  EditableScene currentScene = widget.scene;
                  EditorLessonLoaded? loadedState;

                  if (state is EditorLessonLoaded) {
                    loadedState = state;
                  } else if (state is EditorTranslating) {
                    loadedState = state.previousState;
                  } else if (state is EditorError && state.previousState is EditorLessonLoaded) {
                    loadedState = state.previousState as EditorLessonLoaded;
                  }

                  if (loadedState != null && widget.sceneIndex < loadedState.editableScenes.length) {
                    currentScene = loadedState.editableScenes[widget.sceneIndex];
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _DialogueTab(
                        sceneIndex: widget.sceneIndex,
                        scene: currentScene,
                      ),
                      _CharacterTab(
                        sceneIndex: widget.sceneIndex,
                        scene: currentScene,
                      ),
                      _SettingsTab(
                        sceneIndex: widget.sceneIndex,
                        scene: currentScene,
                      ),
                      _AnimalsTab(
                        sceneIndex: widget.sceneIndex,
                        scene: currentScene,
                      ),
                      ScenePreviewWidget(
                        scene: currentScene,
                        autoPlay: false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogueTab extends StatelessWidget {
  final int sceneIndex;
  final EditableScene scene;

  const _DialogueTab({
    required this.sceneIndex,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return DialogueEditor(
      sceneIndex: sceneIndex,
      dialogues: scene.dialogues,
      onDialogueChanged: (languageCode, text) {
        context.read<EditorBloc>().add(UpdateSceneDialogue(
          sceneIndex: sceneIndex,
          languageCode: languageCode,
          newText: text,
        ));
      },
      onTranslate: (sourceLanguage) {
        context.read<EditorBloc>().add(TranslateDialogue(
          sceneIndex: sceneIndex,
          sourceLanguage: sourceLanguage,
        ));
      },
      onSplit: (position) {
        context.read<EditorBloc>().add(SplitScene(
          sceneIndex: sceneIndex,
          splitPosition: position,
        ));
        Navigator.of(context).pop();
      },
    );
  }
}

class _CharacterTab extends StatelessWidget {
  final int sceneIndex;
  final EditableScene scene;

  const _CharacterTab({
    required this.sceneIndex,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main character
          const Text(
            'Main Character',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          CharacterPicker(
            selectedCharacter: scene.character,
            selectedAnimation: scene.animation,
            selectedEmotion: scene.emotion,
            onChanged: (character, animation, emotion) {
              context.read<EditorBloc>().add(UpdateSceneCharacter(
                sceneIndex: sceneIndex,
                character: character,
                animation: animation,
                emotion: emotion,
              ));
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Second character
          Row(
            children: [
              const Text(
                'Second Character',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (scene.secondCharacter != null)
                TextButton.icon(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  label: const Text('Remove'),
                  onPressed: () {
                    context.read<EditorBloc>().add(UpdateSecondCharacter(
                      sceneIndex: sceneIndex,
                      character: null,
                      animation: null,
                      emotion: null,
                    ));
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          CharacterPicker(
            selectedCharacter: scene.secondCharacter,
            selectedAnimation: scene.secondAnimation,
            selectedEmotion: scene.secondEmotion,
            onChanged: (character, animation, emotion) {
              context.read<EditorBloc>().add(UpdateSecondCharacter(
                sceneIndex: sceneIndex,
                character: character,
                animation: animation,
                emotion: emotion,
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final int sceneIndex;
  final EditableScene scene;

  const _SettingsTab({
    required this.sceneIndex,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transition type
          const Text(
            'Transition Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'auto_tts', label: Text('TTS')),
              ButtonSegment(value: 'auto_timer', label: Text('Timer')),
              ButtonSegment(value: 'button', label: Text('Button')),
              ButtonSegment(value: 'task', label: Text('Task')),
            ],
            selected: {scene.transitionType ?? 'auto_tts'},
            onSelectionChanged: (selection) {
              context.read<EditorBloc>().add(UpdateSceneSettings(
                sceneIndex: sceneIndex,
                transitionType: selection.first,
              ));
            },
          ),
          const SizedBox(height: 24),

          // Duration
          const Text(
            'Duration (seconds)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: (scene.duration ?? 3).toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: '${scene.duration ?? 3}s',
                  onChanged: (value) {
                    context.read<EditorBloc>().add(UpdateSceneSettings(
                      sceneIndex: sceneIndex,
                      duration: value.round(),
                    ));
                  },
                ),
              ),
              Text('${scene.duration ?? 3}s'),
            ],
          ),
          const SizedBox(height: 24),

          // Tone
          const Text(
            'Tone',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'friendly',
              'excited',
              'questioning',
              'sad',
              'encouraging',
            ].map((tone) {
              final isSelected = scene.tone == tone;
              return ChoiceChip(
                label: Text(tone),
                selected: isSelected,
                onSelected: (selected) {
                  context.read<EditorBloc>().add(UpdateSceneSettings(
                    sceneIndex: sceneIndex,
                    tone: selected ? tone : null,
                  ));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Button title (if transition is button)
          if (scene.transitionType == 'button') ...[
            const Text(
              'Button Title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'e.g., Continue, Let\'s go!',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: scene.buttonTitles['en'] ?? '',
              ),
              onChanged: (value) {
                context.read<EditorBloc>().add(UpdateSceneSettings(
                  sceneIndex: sceneIndex,
                  buttonTitle: value,
                ));
              },
            ),
            const SizedBox(height: 24),
          ],

          const Divider(),
          const SizedBox(height: 16),

          // Question settings
          const Text(
            'Question Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Is Question'),
            subtitle: const Text('Scene presents a question to answer'),
            value: scene.isQuestion,
            onChanged: (value) {
              context.read<EditorBloc>().add(UpdateSceneSettings(
                sceneIndex: sceneIndex,
                isQuestion: value,
              ));
            },
          ),
          SwitchListTile(
            title: const Text('Wait for Answer'),
            subtitle: const Text('Wait for user to provide answer'),
            value: scene.waitForAnswer,
            onChanged: (value) {
              context.read<EditorBloc>().add(UpdateSceneSettings(
                sceneIndex: sceneIndex,
                waitForAnswer: value,
              ));
            },
          ),
          if (scene.waitForAnswer) ...[
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Correct Answer (number)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: scene.correctAnswer?.toString() ?? '',
              ),
              onChanged: (value) {
                final answer = int.tryParse(value);
                context.read<EditorBloc>().add(UpdateSceneSettings(
                  sceneIndex: sceneIndex,
                  correctAnswer: answer,
                ));
              },
            ),
          ],
          SwitchListTile(
            title: const Text('Is Pause'),
            subtitle: const Text('Scene is a pause moment'),
            value: scene.isPause,
            onChanged: (value) {
              context.read<EditorBloc>().add(UpdateSceneSettings(
                sceneIndex: sceneIndex,
                isPause: value,
              ));
            },
          ),
          SwitchListTile(
            title: const Text('Show Previous Animals'),
            subtitle: const Text('Display animals from previous scenes'),
            value: scene.showPreviousAnimals,
            onChanged: (value) {
              context.read<EditorBloc>().add(UpdateSceneSettings(
                sceneIndex: sceneIndex,
                showPreviousAnimals: value,
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _AnimalsTab extends StatelessWidget {
  final int sceneIndex;
  final EditableScene scene;

  const _AnimalsTab({
    required this.sceneIndex,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    final animals = scene.animals ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Animals in Scene',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Animal'),
                onPressed: () => _showAddAnimalDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (animals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.pets, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No animals in this scene',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final animal = animals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with emoji, type, count, and delete button
                          Row(
                            children: [
                              Text(
                                animal.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      animal.type,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Count: ${animal.count}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditAnimalDialog(
                                  context,
                                  animal,
                                  index,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  final newAnimals = List.of(animals)..removeAt(index);
                                  context.read<EditorBloc>().add(UpdateSceneAnimals(
                                    sceneIndex: sceneIndex,
                                    animals: newAnimals,
                                  ));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Entrance Effect
                          AnimationEffectPicker(
                            label: 'Entrance Effect',
                            selectedEffect: animal.entranceEffect,
                            recommendedEffect: animal.type.getRecommendedEntranceEffect(),
                            availableEffects: _getEntranceEffects(animal.type),
                            onChanged: (effect) {
                              _updateAnimalEffect(
                                context,
                                index,
                                animal,
                                entranceEffect: effect,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Active Effect
                          AnimationEffectPicker(
                            label: 'Active Effect (optional)',
                            selectedEffect: animal.activeEffect,
                            recommendedEffect: animal.type.getRecommendedActiveEffect(),
                            availableEffects: _getActiveEffects(animal.type),
                            onChanged: (effect) {
                              _updateAnimalEffect(
                                context,
                                index,
                                animal,
                                activeEffect: effect,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Exit Effect
                          AnimationEffectPicker(
                            label: 'Exit Effect',
                            selectedEffect: animal.exitEffect,
                            recommendedEffect: animal.type.getRecommendedExitEffect(),
                            availableEffects: _getExitEffects(animal.type),
                            onChanged: (effect) {
                              _updateAnimalEffect(
                                context,
                                index,
                                animal,
                                exitEffect: effect,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAddAnimalDialog(BuildContext parentContext) {
    String selectedType = 'butterfly';
    String selectedEmoji = '🦋';
    int count = 1;

    final animalOptions = {
      'butterfly': '🦋',
      'bird': '🐦',
      'monkey': '🐵',
      'elephant': '🐘',
      'lion': '🦁',
      'hippo': '🦛',
      'fish': '🐟',
      'bee': '🐝',
    };

    showDialog(
      context: parentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Animal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type',
                  border: OutlineInputBorder(),
                ),
                items: animalOptions.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.value} ${e.key}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                      selectedEmoji = animalOptions[value]!;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Count: '),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: count > 1
                        ? () => setState(() => count--)
                        : null,
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: count < 10
                        ? () => setState(() => count++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAnimal = AnimalModel(
                  type: selectedType,
                  emoji: selectedEmoji,
                  count: count,
                );
                final state = parentContext.read<EditorBloc>().state;
                final List<AnimalModel> currentAnimals;
                if (state is EditorLessonLoaded) {
                  currentAnimals = List<AnimalModel>.from(
                    state.editableScenes[sceneIndex].animals ?? [],
                  );
                } else {
                  currentAnimals = [];
                }
                currentAnimals.add(newAnimal);
                parentContext.read<EditorBloc>().add(UpdateSceneAnimals(
                  sceneIndex: sceneIndex,
                  animals: currentAnimals,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAnimalDialog(BuildContext parentContext, AnimalModel animal, int index) {
    int count = animal.count;

    showDialog(
      context: parentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${animal.type}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                animal.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Count: '),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: count > 1
                        ? () => setState(() => count--)
                        : null,
                  ),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: count < 10
                        ? () => setState(() => count++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedAnimal = animal.copyWith(count: count);
                final state = parentContext.read<EditorBloc>().state;
                final List<AnimalModel> currentAnimals;
                if (state is EditorLessonLoaded) {
                  currentAnimals = List<AnimalModel>.from(
                    state.editableScenes[sceneIndex].animals ?? [],
                  );
                } else {
                  currentAnimals = [];
                }
                currentAnimals[index] = updatedAnimal;
                parentContext.read<EditorBloc>().add(UpdateSceneAnimals(
                  sceneIndex: sceneIndex,
                  animals: currentAnimals,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAnimalEffect(
    BuildContext context,
    int animalIndex,
    AnimalModel animal, {
    AnimationEffect? entranceEffect,
    AnimationEffect? activeEffect,
    AnimationEffect? exitEffect,
  }) {
    final updatedAnimal = animal.copyWith(
      entranceEffect: entranceEffect,
      activeEffect: activeEffect,
      exitEffect: exitEffect,
    );

    final state = context.read<EditorBloc>().state;
    final List<AnimalModel> currentAnimals;
    if (state is EditorLessonLoaded) {
      currentAnimals = List<AnimalModel>.from(
        state.editableScenes[sceneIndex].animals ?? [],
      );
    } else {
      currentAnimals = [];
    }

    currentAnimals[animalIndex] = updatedAnimal;
    context.read<EditorBloc>().add(UpdateSceneAnimals(
      sceneIndex: sceneIndex,
      animals: currentAnimals,
    ));
  }

  List<AnimationEffect> _getEntranceEffects(String animalType) {
    final baseEffects = [
      AnimationEffect.appear,
      AnimationEffect.fade,
      AnimationEffect.flyInLeft,
      AnimationEffect.flyInRight,
      AnimationEffect.flyInTop,
      AnimationEffect.flyInBottom,
      AnimationEffect.floatIn,
      AnimationEffect.zoom,
      AnimationEffect.bounce,
    ];

    // Add specific effects based on animal type
    switch (animalType) {
      case 'monkey':
        return [...baseEffects, AnimationEffect.swingDown];
      case 'banana':
        return [...baseEffects, AnimationEffect.rollIn];
      case 'apple':
        return [...baseEffects, AnimationEffect.fallFromTree];
      default:
        return baseEffects;
    }
  }

  List<AnimationEffect> _getActiveEffects(String animalType) {
    final baseEffects = [
      AnimationEffect.idleBobbing,
      AnimationEffect.float,
      AnimationEffect.wiggle,
      AnimationEffect.pulse,
    ];

    // Add specific effects based on animal type
    switch (animalType) {
      case 'butterfly':
        return [...baseEffects, AnimationEffect.flutter];
      case 'turtle':
        return [...baseEffects, AnimationEffect.walkSlow];
      case 'frog':
        return [...baseEffects, AnimationEffect.hop];
      case 'leaf':
        return [...baseEffects, AnimationEffect.waveInBreeze];
      default:
        return baseEffects;
    }
  }

  List<AnimationEffect> _getExitEffects(String animalType) {
    return [
      AnimationEffect.disappear,
      AnimationEffect.fadeOut,
      AnimationEffect.flyOutLeft,
      AnimationEffect.flyOutRight,
      AnimationEffect.flyOutTop,
      AnimationEffect.flyOutBottom,
      AnimationEffect.scaleOut,
      AnimationEffect.dropOut,
    ];
  }
}
