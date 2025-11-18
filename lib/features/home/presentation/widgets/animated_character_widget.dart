import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget displaying animated mascot characters (Orson and Merv) with cycling animations
class AnimatedCharacterWidget extends StatefulWidget {
  const AnimatedCharacterWidget({
    super.key,
  });

  @override
  State<AnimatedCharacterWidget> createState() => _AnimatedCharacterWidgetState();
}

class _AnimatedCharacterWidgetState extends State<AnimatedCharacterWidget> {
  rive.File? riveFile;
  rive.RiveWidgetController? controller;
  rive.ViewModelInstance? viewModel;
  rive.ViewModelInstanceEnum? characterSelectEnum;

  bool isLoading = true;
  String? error;

  // Animation cycle state
  Timer? _animationTimer;
  int _cycleStep = 0;
  String _currentCharacter = 'Orson';

  // Cycle pattern: Orson walk -> Orson wave -> Merv walk -> Merv wave -> repeat
  final List<Map<String, String>> _animationCycle = [
    {'character': 'Orson', 'animation': 'anim_walk_front'},
    {'character': 'Orson', 'animation': 'anim_wave'},
    {'character': 'Merv', 'animation': 'anim_walk_front'},
    {'character': 'Merv', 'animation': 'anim_wave'},
  ];

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

      // Initialize view model for controlling character and animations
      viewModel = controller!.dataBind(rive.DataBind.auto());
      if (viewModel != null) {
        characterSelectEnum = viewModel!.enumerator('CharacterSelect');
      }

      setState(() {
        isLoading = false;
      });

      // Start animation cycle
      _startAnimationCycle();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      debugPrint('❌ Failed to load Rive file: $e');
    }
  }

  void _startAnimationCycle() {
    // Set initial character
    if (characterSelectEnum != null) {
      characterSelectEnum!.value = 'Orson';
    }

    // Start cycling through animations
    _animationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentStep = _animationCycle[_cycleStep];

      // Change character if needed
      if (characterSelectEnum != null) {
        characterSelectEnum!.value = currentStep['character']!;
      }

      // Update current character for greeting text
      setState(() {
        _currentCharacter = currentStep['character']!;
      });

      // Trigger animation
      if (viewModel != null) {
        try {
          final triggerProperty = viewModel!.trigger(currentStep['animation']!);
          triggerProperty?.trigger();
        } catch (e) {
          debugPrint('❌ Error triggering animation: $e');
        }
      }

      // Move to next step in cycle
      _cycleStep = (_cycleStep + 1) % _animationCycle.length;
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    controller?.dispose();
    viewModel?.dispose();
    riveFile?.dispose();
    super.dispose();
  }

  String _getCharacterGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_currentCharacter == 'Orson') {
      return l10n.orsonGreeting;
    } else {
      return l10n.mervGreeting;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Character animation container
        SizedBox(
          width: AppDimensions.characterSize,
          height: AppDimensions.characterSize,
          child: _buildContent(),
        ),

        const SizedBox(height: AppDimensions.paddingMedium),

        // Greeting bubble
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _getCharacterGreeting(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (error != null) {
      // Fallback to emoji if Rive fails to load
      return const Center(
        child: Text('🐘', style: TextStyle(fontSize: 64)),
      );
    }

    if (controller != null) {
      return rive.RiveWidget(
        controller: controller!,
        fit: rive.Fit.contain,
      );
    }

    return const SizedBox();
  }
}
