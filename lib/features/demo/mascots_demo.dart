import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../../core/constants/app_colors.dart';

/// Demo page for Rive mascots with interactive animations
class MascotsDemo extends StatefulWidget {
  const MascotsDemo({super.key});

  @override
  State<MascotsDemo> createState() => _MascotsDemoState();
}

class _MascotsDemoState extends State<MascotsDemo> {
  rive.File? riveFile;
  rive.RiveWidgetController? controller;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      // Load the Rive file
      riveFile = await rive.File.asset(
        'assets/animations/responsive_mascots.riv',
        riveFactory: kIsWeb ? rive.Factory.flutter : rive.Factory.rive,
      );

      // Create controller with state machine
      controller = rive.RiveWidgetController(
        riveFile!,
        stateMachineSelector: rive.StateMachineSelector.byIndex(0),
      );

      setState(() {
        isLoading = false;
      });

      debugPrint('✅ Rive file loaded successfully with State Machine');
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      debugPrint('❌ Failed to load Rive file: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Mascots'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 16),
            Text('Loading Rive animation...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load animation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (controller != null) {
      return _MascotsControls(controller: controller!);
    }

    return const SizedBox();
  }
}

class _MascotsControls extends StatefulWidget {
  final rive.RiveWidgetController controller;

  const _MascotsControls({required this.controller});

  @override
  State<_MascotsControls> createState() => _MascotsControlsState();
}

class _MascotsControlsState extends State<_MascotsControls> {
  String? selectedAnimation;
  rive.ViewModelInstance? viewModel;
  rive.ViewModelInstanceEnum? characterSelectEnum;
  rive.ViewModelInstanceEnum? faceEmotionEnum;

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    try {
      // Try to get view model instance
      viewModel = widget.controller.dataBind(rive.DataBind.auto());
      if (viewModel != null) {
        debugPrint('✅ View model initialized: ${viewModel!.name}');
        debugPrint('   Properties (${viewModel!.properties.length}):');
        for (var prop in viewModel!.properties) {
          debugPrint('   - ${prop.name} (type: ${prop.runtimeType})');
        }

        // Try to check non-trigger properties with different types
        debugPrint('\n🔍 Checking CharacterSelect:');
        var characterSelectNum = viewModel!.number('CharacterSelect');
        var characterSelectEnum = viewModel!.enumerator('CharacterSelect');
        var characterSelectBool = viewModel!.boolean('CharacterSelect');
        debugPrint('   - as number: ${characterSelectNum?.value}');
        debugPrint('   - as enum: ${characterSelectEnum?.value}');
        debugPrint('   - as bool: ${characterSelectBool?.value}');

        debugPrint('\n🔍 Checking FaceEmotion:');
        var faceEmotionNum = viewModel!.number('FaceEmotion');
        var faceEmotionEnum = viewModel!.enumerator('FaceEmotion');
        debugPrint('   - as number: ${faceEmotionNum?.value}');
        debugPrint('   - as enum: ${faceEmotionEnum?.value}');

        debugPrint('\n🔍 Checking Blink:');
        var blinkBool = viewModel!.boolean('Blink');
        var blinkNum = viewModel!.number('Blink');
        var blinkTrigger = viewModel!.trigger('Blink');
        debugPrint('   - as boolean: ${blinkBool?.value}');
        debugPrint('   - as number: ${blinkNum?.value}');
        debugPrint('   - as trigger: ${blinkTrigger != null ? "exists" : "null"}');

        // Store enum references for later use
        this.characterSelectEnum = characterSelectEnum;
        this.faceEmotionEnum = faceEmotionEnum;

        // Try to test different enum values to find all possibilities
        if (characterSelectEnum != null) {
          debugPrint('\n🧪 Testing CharacterSelect enum values:');
          final testValues = ['Orson', 'Merv', 'Magic Merv', 'Cat', 'Wizard'];
          for (var testValue in testValues) {
            try {
              final oldValue = characterSelectEnum.value;
              characterSelectEnum.value = testValue;
              if (characterSelectEnum.value == testValue) {
                debugPrint('   ✓ "$testValue" is valid');
              }
              characterSelectEnum.value = oldValue; // restore
            } catch (e) {
              // Value not valid
            }
          }
        }

        if (faceEmotionEnum != null) {
          debugPrint('\n🧪 Testing FaceEmotion enum values:');
          final testValues = ['Neutral', 'Happy', 'Sad', 'Angry', 'Scared', 'Surprised', 'Excited', 'Worried'];
          for (var testValue in testValues) {
            try {
              final oldValue = faceEmotionEnum.value;
              faceEmotionEnum.value = testValue;
              if (faceEmotionEnum.value == testValue) {
                debugPrint('   ✓ "$testValue" is valid');
              }
              faceEmotionEnum.value = oldValue; // restore
            } catch (e) {
              // Value not valid
            }
          }
        }
      } else {
        debugPrint('⚠️ View model is null - file may not use Data Binding');
      }
    } catch (e) {
      debugPrint('⚠️ Could not initialize view model: $e');
    }
  }

  @override
  void dispose() {
    viewModel?.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> animations = [
    {'name': 'anim_idle', 'label': 'Idle', 'icon': Icons.accessibility_new, 'color': Colors.blue},
    {'name': 'anim_walk_front', 'label': 'Walk', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': 'anim_wave', 'label': 'Wave', 'icon': Icons.waving_hand, 'color': Colors.orange},
    {'name': 'anim_happy', 'label': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.amber},
    {'name': 'anim_sad', 'label': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.blueGrey},
    {'name': 'anim_sadIntense', 'label': 'Very Sad', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.indigo},
    {'name': 'anim_angry', 'label': 'Angry', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    {'name': 'anim_scared', 'label': 'Scared', 'icon': Icons.sentiment_neutral, 'color': Colors.purple},
    {'name': 'anim_cookie', 'label': 'Cookie', 'icon': Icons.cookie, 'color': Colors.brown},
    {'name': 'anim_breathLOOP', 'label': 'Breathe', 'icon': Icons.air, 'color': Colors.cyan},
    {'name': 'anim_reset', 'label': 'Reset', 'icon': Icons.refresh, 'color': Colors.grey},
  ];

  void _triggerAnimation(String animationName) {
    setState(() {
      selectedAnimation = animationName;
    });

    debugPrint('🎬 Attempting to trigger: $animationName');

    if (viewModel != null) {
      try {
        // Get the trigger property and fire it
        final triggerProperty = viewModel!.trigger(animationName);
        if (triggerProperty != null) {
          triggerProperty.trigger();
          debugPrint('✅ Trigger fired successfully: $animationName');
        } else {
          debugPrint('⚠️ Trigger not found: $animationName');
        }
      } catch (e) {
        debugPrint('❌ Error firing trigger: $e');
      }
    } else {
      debugPrint('⚠️ View model not initialized');
    }
  }

  void _changeCharacter(String character) {
    if (characterSelectEnum != null) {
      characterSelectEnum!.value = character;
      debugPrint('🎭 Changed character to: $character');
      setState(() {});
    }
  }

  void _changeEmotion(String emotion) {
    if (faceEmotionEnum != null) {
      faceEmotionEnum!.value = emotion;
      debugPrint('😊 Changed emotion to: $emotion');
      setState(() {});
    }
  }

  void _triggerBlink() {
    if (viewModel != null) {
      try {
        final blinkTrigger = viewModel!.trigger('Blink');
        if (blinkTrigger != null) {
          blinkTrigger.trigger();
          debugPrint('👁️ Blink triggered!');
        }
      } catch (e) {
        debugPrint('❌ Error triggering blink: $e');
      }
    }
  }

  Widget _buildCharacterButton(String character, String emoji, Color color) {
    final isSelected = characterSelectEnum?.value == character;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeCharacter(character),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                character,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionButton(String emotion, String emoji) {
    final isSelected = faceEmotionEnum?.value == emotion;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeEmotion(emotion),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 24 : 20),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rive animation display
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[100],
            child: Stack(
              children: [
                rive.RiveWidget(
                  controller: widget.controller,
                  fit: rive.Fit.contain,
                ),
                // Character selector
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCharacterButton('Orson', '🐱', Colors.purple),
                      const SizedBox(width: 8),
                      _buildCharacterButton('Merv', '🧙', Colors.blue),
                    ],
                  ),
                ),
                // Emotion selector
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEmotionButton('Neutral', '😐'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Happy', '😊'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Sad', '😢'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Intense Sad', '😭'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Angry', '😠'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Intense Angry', '😡'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Scared', '😨'),
                        const SizedBox(height: 4),
                        _buildEmotionButton('Eating', '😋'),
                      ],
                    ),
                  ),
                ),
                // Blink button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.amber,
                    onPressed: _triggerBlink,
                    child: const Text('👁️', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animation controls
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Animations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: animations.length,
                    itemBuilder: (context, index) {
                      final anim = animations[index];
                      final isSelected = selectedAnimation == anim['name'];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _triggerAnimation(anim['name']),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (anim['color'] as Color).withValues(alpha: 0.2)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (anim['color'] as Color)
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  anim['icon'] as IconData,
                                  color: anim['color'] as Color,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  anim['label'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: anim['color'] as Color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
