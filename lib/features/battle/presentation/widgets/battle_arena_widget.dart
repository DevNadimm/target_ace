import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';

class BattleArenaWidget extends StatelessWidget {
  final String examTitle;
  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final String selectedOption;
  final int questionSecondsRemaining;
  final bool isSubmitting;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onSubmit;

  const BattleArenaWidget({
    super.key,
    required this.examTitle,
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    required this.questionSecondsRemaining,
    required this.isSubmitting,
    required this.onOptionSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Battle')),
        body: const GradientBackground(
          child: Center(
            child: Text('No questions associated with this exam.'),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(examTitle),
        automaticallyImplyLeading: false, // Block default back arrow
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress & Countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentIndex + 1} of ${questions.length}',
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final minutes = (questionSecondsRemaining ~/ 60).toString().padLeft(2, '0');
                            final seconds = (questionSecondsRemaining % 60).toString().padLeft(2, '0');
                            final timeStr = '$minutes:$seconds';
                            final isTimeLow = questionSecondsRemaining <= 60;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isTimeLow 
                                    ? AppColors.error.withValues(alpha: 0.1) 
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isTimeLow 
                                      ? AppColors.error.withValues(alpha: 0.3) 
                                      : AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedClock01,
                                    color: isTimeLow ? AppColors.error : AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timeStr,
                                    style: AppFonts.body(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isTimeLow ? AppColors.error : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 40),

                    // Question text
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentQuestion['question_text'] as String? ?? '',
                              style: AppFonts.heading(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Option Cards
                            _buildOptionCard('A', currentQuestion['option_a'] as String? ?? '', selectedOption, onOptionSelected),
                            _buildOptionCard('B', currentQuestion['option_b'] as String? ?? '', selectedOption, onOptionSelected),
                            _buildOptionCard('C', currentQuestion['option_c'] as String? ?? '', selectedOption, onOptionSelected),
                            _buildOptionCard('D', currentQuestion['option_d'] as String? ?? '', selectedOption, onOptionSelected),
                          ],
                        ),
                      ),
                    ),

                    // Next/Finish Action
                    SizedBox(
                      width: double.infinity,
                      child: SpringButton(
                        backgroundColor: selectedOption.isEmpty ? AppColors.grey.withValues(alpha: 0.1) : AppColors.primary,
                        shadowColor: Colors.black26,
                        onPressed: selectedOption.isEmpty 
                            ? () => AppNotifier.showSnackBar(context, 'Select an option to advance.', type: MessageType.error)
                            : onSubmit,
                        child: Text(
                          currentIndex == questions.length - 1 ? 'Finish Battle' : 'Submit & Next',
                          style: AppFonts.body(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedOption.isEmpty ? AppColors.textSecondary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSubmitting)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: const Loader(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String key, String optionText, String selectedOption, ValueChanged<String> onOptionSelected) {
    final isSelected = selectedOption == key;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => onOptionSelected(key),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    key,
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  optionText,
                  style: AppFonts.body(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
