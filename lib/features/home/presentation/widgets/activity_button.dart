import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Type of activity button
enum ActivityButtonType {
  watchAgain,
  tryAgain,
  askForHint,
  seeMyScore,
  speak,
  draw,
  think,
}

/// Widget for activity buttons with different styles
class ActivityButton extends StatelessWidget {
  final ActivityButtonType type;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ActivityButton({
    super.key,
    required this.type,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isRoundButton = _isRoundButton(type);

    if (isRoundButton) {
      return _buildRoundButton(context);
    } else {
      return _buildRectangularButton(context);
    }
  }

  /// Check if button should be round
  bool _isRoundButton(ActivityButtonType type) {
    return type == ActivityButtonType.speak ||
        type == ActivityButtonType.draw ||
        type == ActivityButtonType.think;
  }

  /// Build rectangular button (for top row activities)
  Widget _buildRectangularButton(BuildContext context) {
    final color = _getButtonColor(type);

    return SizedBox(
      width: 150,
      height: 140,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: AppColors.borderPrimary.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderPrimary,
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build round button (for bottom row activities)
  Widget _buildRoundButton(BuildContext context) {
    final color = _getButtonColor(type);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderPrimary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderPrimary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Get button color based on type
  Color _getButtonColor(ActivityButtonType type) {
    switch (type) {
      case ActivityButtonType.watchAgain:
        return AppColors.watchAgain;
      case ActivityButtonType.tryAgain:
        return AppColors.tryAgain;
      case ActivityButtonType.askForHint:
        return AppColors.askForHint;
      case ActivityButtonType.seeMyScore:
        return AppColors.seeMyScore;
      case ActivityButtonType.speak:
        return AppColors.speak;
      case ActivityButtonType.draw:
        return AppColors.draw;
      case ActivityButtonType.think:
        return AppColors.think;
    }
  }
}
