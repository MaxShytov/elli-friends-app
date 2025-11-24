import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../bloc/editor_state.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Live Preview виджет для предпросмотра сценки в редакторе
class ScenePreviewWidget extends StatefulWidget {
  final EditableScene scene;
  final bool autoPlay;

  const ScenePreviewWidget({
    super.key,
    required this.scene,
    this.autoPlay = false,
  });

  @override
  State<ScenePreviewWidget> createState() => _ScenePreviewWidgetState();
}

class _ScenePreviewWidgetState extends State<ScenePreviewWidget>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  final _audioManager = AudioManager();
  bool _audioInitialized = false;

  // Rive animation
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  rive.File? _riveFile;
  rive.RiveWidgetController? _riveController;
  rive.ViewModelInstance? _viewModel;
  rive.ViewModelInstanceEnum? _characterSelectEnum;
  rive.ViewModelInstanceEnum? _faceEmotionEnum;
  bool _riveLoaded = false;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    // Start bounce animation for animals
    final hasAnimals = widget.scene.animals?.isNotEmpty == true;
    if (hasAnimals) {
      _bounceController.repeat(reverse: true);
    }

    _initializeAudio();

    if (widget.scene.character != null) {
      _loadRiveFile();
    }

    if (widget.autoPlay) {
      _play();
    }
  }

  Future<void> _initializeAudio() async {
    await _audioManager.initialize(languageCode: 'en');
    setState(() {
      _audioInitialized = true;
    });
  }

  Future<void> _loadRiveFile() async {
    try {
      _viewModel?.dispose();
      _riveController?.dispose();

      setState(() {
        _riveLoaded = false;
      });

      _riveFile = await rive.File.asset(
        'assets/animations/responsive_mascots.riv',
        riveFactory: kIsWeb ? rive.Factory.flutter : rive.Factory.rive,
      );

      _riveController = rive.RiveWidgetController(
        _riveFile!,
        stateMachineSelector: rive.StateMachineSelector.byIndex(0),
      );

      _viewModel = _riveController!.dataBind(rive.DataBind.auto());
      if (_viewModel != null) {
        _characterSelectEnum = _viewModel!.enumerator('CharacterSelect');
        _faceEmotionEnum = _viewModel!.enumerator('FaceEmotion');

        final characterName = _getCharacterName(widget.scene.character!);
        if (_characterSelectEnum != null) {
          _characterSelectEnum!.value = characterName;
        }

        if (widget.scene.emotion != null && _faceEmotionEnum != null) {
          _faceEmotionEnum!.value = widget.scene.emotion!;
        }

        if (widget.scene.animation != null) {
          _triggerAnimation(widget.scene.animation!);
        }
      }

      if (mounted) {
        setState(() {
          _riveLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load Rive file: $e');
    }
  }

  void _triggerAnimation(String animationName) {
    if (_viewModel != null) {
      try {
        final triggerProperty = _viewModel!.trigger(animationName);
        if (triggerProperty != null) {
          triggerProperty.trigger();
        }
      } catch (e) {
        debugPrint('❌ Error triggering animation: $e');
      }
    }
  }

  String _getCharacterName(String character) {
    switch (character.toLowerCase()) {
      case 'orson':
      case 'орсон':
        return 'Orson';
      case 'merv':
      case 'мерв':
        return 'Merv';
      default:
        return 'Orson';
    }
  }

  @override
  void didUpdateWidget(ScenePreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scene != widget.scene) {
      // Reload character if changed
      if (widget.scene.character != oldWidget.scene.character &&
          widget.scene.character != null) {
        _loadRiveFile();
      } else {
        // Update emotion if changed
        if (widget.scene.emotion != oldWidget.scene.emotion &&
            widget.scene.emotion != null &&
            _faceEmotionEnum != null) {
          _faceEmotionEnum!.value = widget.scene.emotion!;
        }

        // Trigger animation if changed
        if (widget.scene.animation != null &&
            widget.scene.animation != oldWidget.scene.animation) {
          _triggerAnimation(widget.scene.animation!);
        }
      }

      // Update bounce animation for animals
      final hasAnimals = widget.scene.animals?.isNotEmpty == true;
      if (hasAnimals) {
        _bounceController.repeat(reverse: true);
      } else {
        _bounceController.stop();
      }
    }
  }

  void _play() async {
    if (!_audioInitialized) {
      debugPrint('⚠️ Audio not initialized yet');
      return;
    }

    setState(() {
      _isPlaying = true;
    });

    // Trigger talking animation if character exists
    if (widget.scene.animation != null) {
      _triggerAnimation(widget.scene.animation!);
    } else if (_viewModel != null) {
      // Default talking animation
      try {
        final talkingTrigger = _viewModel!.trigger('talking');
        if (talkingTrigger != null) {
          talkingTrigger.trigger();
        }
      } catch (e) {
        debugPrint('⚠️ No talking animation available: $e');
      }
    }

    // Play dialogue with TTS
    if (widget.scene.dialogues['en']?.isNotEmpty == true &&
        widget.scene.character != null) {
      await _audioManager.speakDialogue(
        widget.scene.dialogues['en']!,
        character: widget.scene.character!,
      );
    }

    setState(() {
      _isPlaying = false;
    });
  }

  void _stop() {
    _audioManager.stopSpeaking();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _riveController?.dispose();
    _viewModel?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          // Background
          if (widget.scene.background != null)
            _buildBackground(widget.scene.background!),

          // Scene content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Character (Rive animation)
                  if (widget.scene.character != null)
                    _buildCharacter(widget.scene.character!),

                  if (widget.scene.character != null)
                    const SizedBox(height: 16),

                  // Dialogue
                  if (widget.scene.dialogues['en']?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.scene.dialogues['en']!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Animals
                  if (widget.scene.animals?.isNotEmpty == true)
                    _buildAnimals(widget.scene.animals!),
                ],
              ),
            ),
          ),

          // Play/Stop controls
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _isPlaying ? _stop : _play,
              child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            ),
          ),

          // Loading indicator for Rive
          if (widget.scene.character != null && !_riveLoaded)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacter(String character) {
    if (_riveLoaded && _riveController != null) {
      return SizedBox(
        width: 300,
        height: 300,
        child: rive.RiveWidget(
          controller: _riveController!,
          fit: rive.Fit.contain,
        ),
      );
    }

    // Fallback to emoji while loading
    final emoji = _getCharacterEmoji(character);
    return Container(
      width: AppDimensions.characterSize,
      height: AppDimensions.characterSize,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  String _getCharacterEmoji(String character) {
    switch (character.toLowerCase()) {
      case 'orson':
      case 'орсон':
        return '🐱';
      case 'merv':
      case 'мерв':
        return '🧙';
      default:
        return '😊';
    }
  }

  Widget _buildAnimals(List animals) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: animals.map((animal) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            animal.count,
            (index) => AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bounceAnimation.value),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      animal.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBackground(String background) {
    Color bgColor;
    switch (background) {
      case 'jungle_morning':
        bgColor = Colors.green[100]!;
        break;
      case 'jungle_evening':
        bgColor = Colors.orange[100]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }
}
