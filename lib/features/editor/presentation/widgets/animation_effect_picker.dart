import 'package:flutter/material.dart';
import '../../../lessons/domain/entities/animation_effect.dart';

/// Виджет для выбора анимационного эффекта
class AnimationEffectPicker extends StatelessWidget {
  final String label;
  final AnimationEffect? selectedEffect;
  final AnimationEffect? recommendedEffect;
  final List<AnimationEffect> availableEffects;
  final Function(AnimationEffect?) onChanged;

  const AnimationEffectPicker({
    super.key,
    required this.label,
    this.selectedEffect,
    this.recommendedEffect,
    required this.availableEffects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (recommendedEffect != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Chip(
                  label: Text(
                    'Recommended: ${_effectToString(recommendedEffect!)}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: Colors.green[100],
                  avatar: const Icon(Icons.lightbulb_outline, size: 16),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnimationEffect?>(
          initialValue: selectedEffect,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            const DropdownMenuItem<AnimationEffect?>(
              value: null,
              child: Text('None'),
            ),
            ...availableEffects.map((effect) {
              return DropdownMenuItem<AnimationEffect?>(
                value: effect,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _effectToString(effect),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (effect == recommendedEffect) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    ],
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
        if (recommendedEffect != null && selectedEffect != recommendedEffect)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.auto_fix_high, size: 16),
              label: const Text('Use recommended'),
              onPressed: () => onChanged(recommendedEffect),
            ),
          ),
      ],
    );
  }

  String _effectToString(AnimationEffect effect) {
    return effect.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
