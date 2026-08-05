import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class OptionCard extends StatelessWidget {
  final String label;
  final String text;
  final String correctAnswer;
  final String? selectedOption;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.label,
    required this.text,
    required this.correctAnswer,
    required this.selectedOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAnswered = selectedOption != null;
    final bool isSelected = selectedOption == label;
    final bool isCorrect = correctAnswer.toUpperCase() == label;

    Color borderColor = AppColors.inputBorder;
    Color textColor = AppColors.textPrimary;

    if (hasAnswered) {
      if (isCorrect) {
        borderColor = AppColors.success.withValues(alpha: 0.5);
        textColor = AppColors.success;
      } else if (isSelected) {
        borderColor = AppColors.error.withValues(alpha: 0.5);
        textColor = AppColors.error;
      } else {
        borderColor = AppColors.inputBorder;
        textColor = AppColors.textSecondary;
      }
    } else {
      borderColor = AppColors.inputBorder;
      textColor = AppColors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CustomContainer(
        onTap: hasAnswered ? null : onTap,
        color: Color.alphaBlend(borderColor.withValues(alpha: 0.1), AppColors.background),
        borderColor: borderColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCorrect ? AppColors.success : AppColors.error)
                    : (hasAnswered && isCorrect ? AppColors.success : AppColors.black),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected || (hasAnswered && isCorrect)
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}