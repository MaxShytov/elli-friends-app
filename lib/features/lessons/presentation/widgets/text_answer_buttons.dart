import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget for displaying text answer buttons during lessons
class TextAnswerButtons extends StatelessWidget {
  final List<AnswerOption> options;
  final Function(dynamic) onAnswer;
  final dynamic selectedAnswer;
  final dynamic correctAnswer;

  const TextAnswerButtons({
    super.key,
    required this.options,
    required this.onAnswer,
    this.selectedAnswer,
    this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = selectedAnswer != null &&
            selectedAnswer.toString().toLowerCase() == option.value.toString().toLowerCase();
        final isCorrect = correctAnswer != null &&
            correctAnswer.toString().toLowerCase() == option.value.toString().toLowerCase();
        final isDisabled = selectedAnswer != null && !isSelected;

        return _TextAnswerButton(
          label: option.label,
          onTap: selectedAnswer == null ? () => onAnswer(option.value) : null,
          isSelected: isSelected,
          isCorrect: isCorrect,
          isDisabled: isDisabled,
        );
      }).toList(),
    );
  }
}

class _TextAnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisabled;

  const _TextAnswerButton({
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isDisabled = false,
  });

  Color _getButtonColor() {
    if (isCorrect) return AppColors.correct;
    if (isDisabled) return Colors.grey.shade400;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getButtonColor(),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      elevation: isDisabled ? 1 : 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 80,
            minHeight: 56,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey.shade600 : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
