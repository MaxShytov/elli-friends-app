import 'package:flutter/material.dart';

/// Widget for selecting character, animation, and emotion
class CharacterPicker extends StatelessWidget {
  final String? selectedCharacter;
  final String? selectedAnimation;
  final String? selectedEmotion;
  final void Function(String? character, String? animation, String? emotion)
      onChanged;

  const CharacterPicker({
    super.key,
    this.selectedCharacter,
    this.selectedAnimation,
    this.selectedEmotion,
    required this.onChanged,
  });

  static const characters = [
    ('orson', '🦁', 'Orson the Lion'),
    ('merv', '🧙', 'Merv the Wizard'),
    ('elli', '🐘', 'Elli the Elephant'),
    ('bono', '🐘', 'Bono the Baby Elephant'),
    ('hippo', '🦛', 'Hippo'),
  ];

  static const animations = [
    'anim_idle',
    'anim_wave',
    'anim_happy',
    'anim_sad',
    'anim_walk_front',
    'anim_eating',
    'anim_thinking',
  ];

  static const emotions = [
    'Happy',
    'Sad',
    'Neutral',
    'Eating',
    'Intense Sad',
    'Angry',
    'Surprised',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Character selection
        const Text(
          'Character',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: characters.map((char) {
            final isSelected = selectedCharacter == char.$1;
            return InkWell(
              onTap: () => onChanged(char.$1, selectedAnimation, selectedEmotion),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getCharacterColor(char.$1).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? _getCharacterColor(char.$1)
                        : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(char.$2, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      char.$1,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? _getCharacterColor(char.$1)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Animation selection
        const Text(
          'Animation',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedAnimation,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: animations.map((anim) {
            return DropdownMenuItem(
              value: anim,
              child: Text(_formatAnimationName(anim)),
            );
          }).toList(),
          onChanged: (value) {
            onChanged(selectedCharacter, value, selectedEmotion);
          },
        ),
        const SizedBox(height: 16),

        // Emotion selection
        const Text(
          'Emotion',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: emotions.map((emotion) {
            final isSelected = selectedEmotion == emotion;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getEmotionEmoji(emotion)),
                  const SizedBox(width: 4),
                  Text(emotion),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(
                  selectedCharacter,
                  selectedAnimation,
                  selected ? emotion : null,
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getCharacterColor(String character) {
    switch (character.toLowerCase()) {
      case 'orson':
        return Colors.orange;
      case 'merv':
        return Colors.purple;
      case 'elli':
        return Colors.pink;
      case 'bono':
        return Colors.blue;
      case 'hippo':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatAnimationName(String animation) {
    return animation
        .replaceAll('anim_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'neutral':
        return '😐';
      case 'eating':
        return '😋';
      case 'intense sad':
        return '😭';
      case 'angry':
        return '😠';
      case 'surprised':
        return '😮';
      default:
        return '😊';
    }
  }
}
