import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/profile/presentation/widgets/step_progress_bar.dart';

class ActiveBattleView extends StatefulWidget {
  final String examTitle;
  final List<QuestionEntity> questions;
  final int currentIndex;
  final String selectedOption;
  final List<Map<String, dynamic>> userAnswersList;
  final ValueNotifier<int> secondsNotifier;
  final bool isSubmitting;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onSubmit;
  final ValueChanged<int>? onQuestionJumped;

  const ActiveBattleView({
    super.key,
    required this.examTitle,
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    this.userAnswersList = const [],
    required this.secondsNotifier,
    required this.isSubmitting,
    required this.onOptionSelected,
    required this.onSubmit,
    this.onQuestionJumped,
  });

  @override
  State<ActiveBattleView> createState() => _ActiveBattleViewState();
}

class _ActiveBattleViewState extends State<ActiveBattleView> {
  late final ScrollController _paletteScrollController;

  @override
  void initState() {
    super.initState();
    _paletteScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant ActiveBattleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _paletteScrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (!_paletteScrollController.hasClients) return;
    const itemWidth = 38.0; // 32.0 circle width + 6.0 separator spacing
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    final maxExtent = _paletteScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxExtent);

    _paletteScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Battle')),
        body: const GradientBackground(
          child: Center(
            child: Text('No questions associated with this exam.'),
          ),
        ),
      );
    }

    final currentQuestion = widget.questions[widget.currentIndex];
    final answeredCount = widget.userAnswersList.where((a) => (a['status'] as String? ?? '') == 'answered').length;
    final skippedCount = widget.userAnswersList.where((a) => (a['status'] as String? ?? '') == 'skipped').length;
    final unansweredCount = widget.questions.length - answeredCount - skippedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examTitle),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${widget.currentIndex + 1} of ${widget.questions.length}',
                            style: AppFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: widget.secondsNotifier,
                            builder: (context, questionSecondsRemaining, _) {
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
                    ),
                    const SizedBox(height: 12),

                    // Compact Live Counters Badge Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildStatusBadge(
                            label: '$answeredCount Ans',
                            color: AppColors.success,
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          ),
                          const SizedBox(width: 6),
                          _buildStatusBadge(
                            label: '$skippedCount Skip',
                            color: AppColors.warning,
                            icon: HugeIcons.strokeRoundedAlertCircle,
                          ),
                          const SizedBox(width: 6),
                          _buildStatusBadge(
                            label: '$unansweredCount Left',
                            color: AppColors.textSecondary,
                            icon: HugeIcons.strokeRoundedHelpCircle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StepProgressBar(
                        currentStep: widget.currentIndex,
                        totalSteps: widget.questions.length,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horizontal Question Palette Bar
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        controller: _paletteScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.questions.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 6),
                        itemBuilder: (context, idx) {
                          final isCurrent = idx == widget.currentIndex;
                          final itemStatus = idx < widget.userAnswersList.length ? (widget.userAnswersList[idx]['status'] as String? ?? 'unvisited') : 'unvisited';
                          final isSkipped = itemStatus == 'skipped';
                          final isAnswered = itemStatus == 'answered';

                          Border border = Border.all(color: AppColors.cardAlt, width: 2);
                          Color pillColor = AppColors.cardAlt;
                          Color textColor = AppColors.textSecondary;

                          if (isCurrent) {
                            border = Border.all(color: AppColors.primary, width: 2);
                            pillColor = AppColors.primary.withValues(alpha: 0.15);
                            textColor = AppColors.primary;
                          } else if (isAnswered) {
                            border = Border.all(color: AppColors.success, width: 2);
                            pillColor = AppColors.success;
                            textColor = Colors.white;
                          } else if (isSkipped) {
                            border = Border.all(color: AppColors.warning, width: 2);
                            pillColor = AppColors.warning;
                            textColor = Colors.white;
                          }

                          return GestureDetector(
                            onTap: () => widget.onQuestionJumped?.call(idx),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: pillColor,
                                shape: BoxShape.circle,
                                border: border,
                              ),
                              child: Text(
                                '${idx + 1}',
                                style: AppFonts.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Question text
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomContainer(
                              width: double.infinity,
                              child: Text(
                                currentQuestion.questionText,
                                style: AppFonts.heading(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Option Cards
                            _buildOptionCard('A', currentQuestion.optionA, widget.selectedOption, widget.onOptionSelected),
                            _buildOptionCard('B', currentQuestion.optionB, widget.selectedOption, widget.onOptionSelected),
                            if (currentQuestion.optionC.isNotEmpty)
                              _buildOptionCard('C', currentQuestion.optionC, widget.selectedOption, widget.onOptionSelected),
                            if (currentQuestion.optionD.isNotEmpty)
                              _buildOptionCard('D', currentQuestion.optionD, widget.selectedOption, widget.onOptionSelected),
                          ],
                        ),
                      ),
                    ),

                    // Next / Skip / Finish Action Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: SpringButton(
                          onPressed: widget.onSubmit,
                          child: Text(
                            widget.selectedOption.isEmpty
                                ? (widget.currentIndex == widget.questions.length - 1 ? 'Skip & Finish' : 'Skip & Next')
                                : (widget.currentIndex == widget.questions.length - 1 ? 'Finish Battle' : 'Submit & Next'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSubmitting)
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

    Color borderColor = isSelected ? AppColors.primary : AppColors.inputBorder;
    Color textColor = isSelected ? AppColors.primary : AppColors.textPrimary;
    Color circleColor = isSelected ? AppColors.primary : AppColors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CustomContainer(
        onTap: () => onOptionSelected(key),
        color: Color.alphaBlend(borderColor.withValues(alpha: 0.1), AppColors.background),
        borderColor: borderColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  key,
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                optionText,
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

  Widget _buildStatusBadge({
    required String label,
    required Color color,
    required List<List<dynamic>> icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}