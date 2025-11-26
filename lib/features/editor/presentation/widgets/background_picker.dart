import 'package:flutter/material.dart';

/// Виджет для выбора фона сценки
class BackgroundPicker extends StatelessWidget {
  final String? selectedBackground;
  final Function(String?) onChanged;

  const BackgroundPicker({
    super.key,
    this.selectedBackground,
    required this.onChanged,
  });

  static const backgrounds = {
    'jungle_morning': {'name': 'Jungle Morning', 'color': Colors.lightGreen},
    'jungle_evening': {'name': 'Jungle Evening', 'color': Colors.orange},
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBackgroundOption(context, null, 'None', Colors.grey[300]!),
            ...backgrounds.entries.map((entry) {
              return _buildBackgroundOption(
                context,
                entry.key,
                entry.value['name'] as String,
                entry.value['color'] as Color,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundOption(
    BuildContext context,
    String? value,
    String label,
    Color color,
  ) {
    final isSelected = selectedBackground == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[400]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.purple),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
