import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';

class ExamReviewPage extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> userAnswers;

  const ExamReviewPage({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  static Route route({
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> userAnswers,
  }) {
    return MaterialPageRoute(
      builder: (_) => ExamReviewPage(
        questions: questions,
        userAnswers: userAnswers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
        leading: const BackButton(),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: questions.isEmpty
              ? const Center(
                  child: Text('No questions to review.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final questionId = question['id'] as String;

                    // Find user's answer
                    final userAnswer = userAnswers.firstWhere(
                      (ans) => ans['question_id'] == questionId,
                      orElse: () => <String, dynamic>{
                        'question_id': questionId,
                        'selected': '',
                        'correct': question['correct_option'] as String,
                        'is_correct': false,
                      },
                    );

                    final selectedOption = userAnswer['selected'] as String;
                    final correctOption = userAnswer['correct'] as String;
                    final isCorrect = userAnswer['is_correct'] as bool;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: CustomContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question header / number
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${index + 1}',
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (selectedOption.isEmpty)
                                        ? AppColors.grey.withValues(alpha: 0.1)
                                        : isCorrect
                                            ? AppColors.success.withValues(alpha: 0.1)
                                            : AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    selectedOption.isEmpty
                                        ? 'Unanswered'
                                        : isCorrect
                                            ? 'Correct'
                                            : 'Incorrect',
                                    style: AppFonts.body(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: selectedOption.isEmpty
                                          ? AppColors.textSecondary
                                          : isCorrect
                                              ? AppColors.success
                                              : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Question text
                            Text(
                              question['question_text'] as String? ?? '',
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Options
                            _buildReviewOption(context, 'A', question['option_a'] as String? ?? '', selectedOption, correctOption),
                            _buildReviewOption(context, 'B', question['option_b'] as String? ?? '', selectedOption, correctOption),
                            _buildReviewOption(context, 'C', question['option_c'] as String? ?? '', selectedOption, correctOption),
                            _buildReviewOption(context, 'D', question['option_d'] as String? ?? '', selectedOption, correctOption),

                            // Explanation Card
                            if (question['explanation'] != null && (question['explanation'] as String).trim().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const CustomDivider.dotted(),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const HugeIcon(
                                    icon: HugeIcons.strokeRoundedInformationCircle,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Explanation:',
                                          style: AppFonts.body(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          question['explanation'] as String,
                                          style: AppFonts.body(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildReviewOption(
    BuildContext context,
    String key,
    String optionText,
    String selectedOption,
    String correctOption,
  ) {
    final isSelected = selectedOption == key;
    final isCorrect = correctOption == key;

    Color containerColor = AppColors.card;
    Color borderColor = AppColors.divider;
    Color keyBgColor = AppColors.divider;
    Color keyTextColor = AppColors.textSecondary;
    dynamic suffixIcon;
    Color? suffixIconColor;

    if (isCorrect) {
      containerColor = AppColors.success.withValues(alpha: 0.08);
      borderColor = AppColors.success.withValues(alpha: 0.4);
      keyBgColor = AppColors.success;
      keyTextColor = Colors.white;
      suffixIcon = HugeIcons.strokeRoundedCheckmarkCircle02;
      suffixIconColor = AppColors.success;
    } else if (isSelected) {
      containerColor = AppColors.error.withValues(alpha: 0.08);
      borderColor = AppColors.error.withValues(alpha: 0.4);
      keyBgColor = AppColors.error;
      keyTextColor = Colors.white;
      suffixIcon = HugeIcons.strokeRoundedCancelCircle;
      suffixIconColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: keyBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                key,
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: keyTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              optionText,
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: isSelected || isCorrect ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (suffixIcon != null)
            HugeIcon(
              icon: suffixIcon,
              color: suffixIconColor ?? Colors.grey,
              size: 20,
            ),
        ],
      ),
    );
  }
}
