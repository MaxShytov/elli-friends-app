import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget for displaying answer buttons during lessons
class AnswerButtons extends StatelessWidget {
  final int maxNumber;
  final Function(int) onAnswer;
  final int? selectedAnswer;
  final int? correctAnswer;

  const AnswerButtons({
    super.key,
    required this.maxNumber,
    required this.onAnswer,
    this.selectedAnswer,
    this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(
        maxNumber,
        (index) {
          final number = index + 1;
          final isSelected = selectedAnswer == number;
          final isCorrect = correctAnswer == number;
          final isDisabled = selectedAnswer != null && !isSelected;

          return _AnswerButton(
            number: number,
            onTap: selectedAnswer == null ? () => onAnswer(number) : null,
            isSelected: isSelected,
            isCorrect: isCorrect,
            isDisabled: isDisabled,
          );
        },
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final int number;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisabled;

  const _AnswerButton({
    required this.number,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isDisabled = false,
  });

  Color _getButtonColor() {
    if (isCorrect) {
      return AppColors.correct;
    } else if (isDisabled) {
      return Colors.grey.shade400;
    }
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
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey.shade600 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
