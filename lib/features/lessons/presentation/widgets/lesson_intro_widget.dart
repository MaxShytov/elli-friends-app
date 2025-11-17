import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget for displaying lesson introduction/summary
class LessonIntroWidget extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onStart;

  const LessonIntroWidget({
    super.key,
    required this.lesson,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Topic emoji/icon
          _buildTopicIcon(),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Title
          Text(
            lesson.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Description card
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Description text
                Text(
                  lesson.description,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Difficulty indicator
                _buildDifficultyIndicator(context),

                const SizedBox(height: AppDimensions.paddingSmall),

                // Tags
                if (lesson.tags.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _buildTags(context),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingXLarge),

          // Start button
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.correct,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXLarge * 2,
                vertical: AppDimensions.paddingLarge,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.start,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                const Icon(Icons.play_arrow, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicIcon() {
    String emoji;
    Color bgColor;

    switch (lesson.topic.toLowerCase()) {
      case 'counting':
        emoji = '🔢';
        bgColor = AppColors.elliBg;
        break;
      case 'colors':
        emoji = '🎨';
        bgColor = AppColors.bonoBg;
        break;
      case 'animals':
        emoji = '🦁';
        bgColor = AppColors.hippoBg;
        break;
      default:
        emoji = '📚';
        bgColor = AppColors.cardBg;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
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

  Widget _buildDifficultyIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.stars_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: AppDimensions.paddingSmall),
        Text(
          _getDifficultyText(context),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (lesson.difficulty) {
      case 1:
        return l10n.difficultyEasy;
      case 2:
        return l10n.difficultyMedium;
      case 3:
        return l10n.difficultyHard;
      default:
        return l10n.difficultyLevel(lesson.difficulty);
    }
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingSmall,
      runSpacing: AppDimensions.paddingSmall,
      alignment: WrapAlignment.center,
      children: lesson.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall / 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Text(
            '#$tag',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
