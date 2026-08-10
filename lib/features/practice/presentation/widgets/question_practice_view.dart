import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/practice/presentation/widgets/question_options_bottom_sheet.dart';
import 'package:target_ace/features/practice/presentation/widgets/explanation_card.dart';
import 'package:target_ace/features/practice/presentation/widgets/option_card.dart';

class QuestionPracticeView extends StatefulWidget {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final String? selectedOption;
  final bool isBookmarked;
  final bool? previousAttemptIsCorrect;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onReportError;

  const QuestionPracticeView({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    this.isBookmarked = false,
    this.previousAttemptIsCorrect,
    required this.onOptionSelected,
    required this.onNext,
    required this.onPrevious,
    this.onToggleBookmark,
    this.onReportError,
  });

  @override
  State<QuestionPracticeView> createState() => _QuestionPracticeViewState();
}

class _QuestionPracticeViewState extends State<QuestionPracticeView> {
  bool _isForward = true;

  @override
  void didUpdateWidget(QuestionPracticeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _isForward = widget.currentIndex > oldWidget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.questions[widget.currentIndex];
    final questionText = currentQ.questionText;
    final optionA = currentQ.optionA;
    final optionB = currentQ.optionB;
    final optionC = currentQ.optionC;
    final optionD = currentQ.optionD;
    final correctAnswer = currentQ.correctOption;
    final difficulty = currentQ.difficultyLevel;
    final explanation = currentQ.explanation;

    final bool hasAnswered = widget.selectedOption != null;

    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final isIncoming =
                  child.key == ValueKey<int>(widget.currentIndex);
              final offsetAnimation = Tween<Offset>(
                begin: isIncoming
                    ? Offset(_isForward ? 1.0 : -1.0, 0.0)
                    : Offset(_isForward ? -1.0 : 1.0, 0.0),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(position: offsetAnimation, child: child);
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  ?currentChild,
                ],
              );
            },
            child: SingleChildScrollView(
              key: ValueKey<int>(widget.currentIndex),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${widget.currentIndex + 1} of ${widget.questions.length}',
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.previousAttemptIsCorrect != null && !hasAnswered) ...[
                            Row(
                              children: [
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedBook02,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'REVISION',
                                  style: AppFonts.body(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            'LVL $difficulty',
                            style: AppFonts.body(
                              fontSize: 10,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomIconButton(
                            backgroundColor: AppColors.card,
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedMoreVertical,
                              color: AppColors.textPrimary,
                            ),
                            tooltip: 'Options',
                            onTap: () {
                              QuestionOptionsBottomSheet.show(
                                context,
                                isBookmarked: widget.isBookmarked,
                                onToggleBookmark: widget.onToggleBookmark,
                                onReportError: widget.onReportError,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomContainer(
                    width: double.infinity,
                    child: Text(
                      questionText,
                      style: AppFonts.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  OptionCard(
                    label: 'A',
                    text: optionA,
                    correctAnswer: correctAnswer,
                    selectedOption: widget.selectedOption,
                    onTap: () => widget.onOptionSelected('A'),
                  ),
                  OptionCard(
                    label: 'B',
                    text: optionB,
                    correctAnswer: correctAnswer,
                    selectedOption: widget.selectedOption,
                    onTap: () => widget.onOptionSelected('B'),
                  ),
                  if (optionC.isNotEmpty)
                    OptionCard(
                      label: 'C',
                      text: optionC,
                      correctAnswer: correctAnswer,
                      selectedOption: widget.selectedOption,
                      onTap: () => widget.onOptionSelected('C'),
                    ),
                  if (optionD.isNotEmpty)
                    OptionCard(
                      label: 'D',
                      text: optionD,
                      correctAnswer: correctAnswer,
                      selectedOption: widget.selectedOption,
                      onTap: () => widget.onOptionSelected('D'),
                    ),
                  if (hasAnswered && widget.previousAttemptIsCorrect != null) ...[
                    Builder(
                      builder: (context) {
                        final isCurrentCorrect = widget.selectedOption?.toUpperCase() == correctAnswer.toUpperCase();
                        final isPreviousCorrect = widget.previousAttemptIsCorrect!;
                        
                        String message;
                        Color bannerColor;
                        List<List<dynamic>> bannerIcon;
                        
                        if (isCurrentCorrect && isPreviousCorrect) {
                          message = "Great! You answered this correctly last time too. Keep up the great work!";
                          bannerColor = AppColors.success;
                          bannerIcon = HugeIcons.strokeRoundedTick01;
                        } else if (isCurrentCorrect && !isPreviousCorrect) {
                          message = "Awesome! You improved! You got this right after missing it last time!";
                          bannerColor = AppColors.success;
                          bannerIcon = HugeIcons.strokeRoundedTick01;
                        } else if (!isCurrentCorrect && isPreviousCorrect) {
                          message = "Oops! You answered this correctly last time, but missed it this time.";
                          bannerColor = AppColors.warning;
                          bannerIcon = HugeIcons.strokeRoundedCancel01;
                        } else {
                          message = "You got this wrong last time too. Let's read the explanation carefully!";
                          bannerColor = AppColors.error;
                          bannerIcon = HugeIcons.strokeRoundedCancel01;
                        }

                        return Column(
                          children: [
                            const SizedBox(height: 22),
                            CustomContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              color: Color.alphaBlend(bannerColor.withValues(alpha: 0.1), AppColors.background),
                              borderColor: bannerColor.withValues(alpha: 0.5),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: bannerColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: HugeIcon(
                                        icon: bannerIcon,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      message,
                                      style: AppFonts.body(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: bannerColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  if (hasAnswered && explanation != null && explanation.isNotEmpty) ...[
                    SizedBox(height: (hasAnswered && widget.previousAttemptIsCorrect != null) ? 12 : 22),
                    ExplanationCard(explanation: explanation),
                  ],
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.currentIndex > 0) ...[
                  Expanded(
                    flex: 1,
                    child: SpringButton(
                      onPressed: widget.onPrevious,
                      backgroundColor: AppColors.card,
                      shadowColor: AppColors.grey,
                      child: Center(
                        child: Text(
                          'PREVIOUS',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: widget.currentIndex > 0 ? 1 : 1,
                  child: SpringButton(
                    onPressed: widget.currentIndex < widget.questions.length - 1
                        ? widget.onNext
                        : null,
                    child: Center(
                      child: Text(
                        'CONTINUE',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}