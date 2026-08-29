import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/bloc/session/practice_session_cubit.dart';
import 'package:target_ace/features/practice/presentation/widgets/explanation_card.dart';
import 'package:target_ace/features/practice/presentation/widgets/option_card.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:hugeicons/hugeicons.dart';

class ReviewAnswersPage extends StatelessWidget {
  final SubjectEntity subject;

  const ReviewAnswersPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Review Answers'),
      ),
      body: GradientBackground(
        child: BlocBuilder<PracticeSessionCubit, PracticeSessionState>(
          builder: (context, state) {
            final cubit = context.read<PracticeSessionCubit>();
            final attempts = cubit.sessionAttempts;

            if (attempts.isEmpty) {
              return Center(
                child: Text(
                  'No questions answered.',
                  style: AppFonts.body(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                final qId = attempt['question_id'];
                final selectedOption = attempt['selected_option'] as String;
                final isCorrect = attempt['is_correct'] as bool;
                
                final question = state.questions.firstWhere((q) => q.id == qId);

                return CustomContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCorrect ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: isCorrect ? HugeIcons.strokeRoundedTick01 : HugeIcons.strokeRoundedCancel01,
                                  color: isCorrect ? AppColors.success : AppColors.error,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCorrect ? 'Correct' : 'Incorrect',
                                  style: AppFonts.body(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.questionText,
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OptionCard(
                        label: 'A',
                        text: question.optionA,
                        correctAnswer: question.correctOption,
                        selectedOption: selectedOption,
                        onTap: () {},
                      ),
                      OptionCard(
                        label: 'B',
                        text: question.optionB,
                        correctAnswer: question.correctOption,
                        selectedOption: selectedOption,
                        onTap: () {},
                      ),
                      if (question.optionC.isNotEmpty)
                        OptionCard(
                          label: 'C',
                          text: question.optionC,
                          correctAnswer: question.correctOption,
                          selectedOption: selectedOption,
                          onTap: () {},
                        ),
                      if (question.optionD.isNotEmpty)
                        OptionCard(
                          label: 'D',
                          text: question.optionD,
                          correctAnswer: question.correctOption,
                          selectedOption: selectedOption,
                          onTap: () {},
                        ),
                      if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ExplanationCard(explanation: question.explanation!),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
