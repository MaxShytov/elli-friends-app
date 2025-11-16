// lib/features/home/presentation/widgets/activity_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/activity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Card widget for displaying an activity option
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  String _getLocalizedTitle(BuildContext context, String titleKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (titleKey) {
      case 'counting':
        return l10n.learnNumbers;
      case 'letters':
        return l10n.learnLetters;
      case 'shapes':
        return l10n.learnShapes;
      case 'colors':
        return l10n.learnColors;
      default:
        return titleKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: activity.isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji
              Opacity(
                opacity: activity.isLocked ? 0.3 : 1.0,
                child: Text(
                  activity.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingSmall),

              // Title (localized)
              Text(
                _getLocalizedTitle(context, activity.title),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: activity.isLocked
                          ? Colors.grey
                          : AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),

              // Lock icon if locked
              if (activity.isLocked) ...[
                const SizedBox(height: AppDimensions.paddingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.requiredStars} ⭐',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
