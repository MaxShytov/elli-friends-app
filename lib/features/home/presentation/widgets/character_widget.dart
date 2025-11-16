import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget displaying Elli the Elephant character with greeting
class CharacterWidget extends StatelessWidget {
  final String emoji;
  final String greeting;
  final bool isAnimating;
  final VoidCallback? onTap;

  const CharacterWidget({
    super.key,
    required this.emoji,
    required this.greeting,
    this.isAnimating = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Character (large emoji)
        GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: isAnimating ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: AppDimensions.characterSize,
              height: AppDimensions.characterSize,
              decoration: BoxDecoration(
                color: AppColors.elliBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.elliDarkBlue,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.elliDarkBlue.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Elephant face emoji
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  // Optional: Add a subtle animation effect
                  if (isAnimating)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
            greeting,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
