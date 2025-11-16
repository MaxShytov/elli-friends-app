import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Widget displaying Elli the Elephant character
class CharacterWidget extends StatelessWidget {
  final bool isAnimating;
  final VoidCallback? onTap;

  const CharacterWidget({
    super.key,
    this.isAnimating = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isAnimating ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.elliBlue,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.elliDarkBlue,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.elliDarkBlue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Elephant face emoji or custom drawing
              const Text(
                '🐘',
                style: TextStyle(fontSize: 80),
              ),
              // Optional: Add a subtle animation effect
              if (isAnimating)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
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
    );
  }
}
