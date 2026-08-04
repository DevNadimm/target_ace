import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

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
        automaticallyImplyLeading: false, // Block default back arrow
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Header & Countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${widget.currentIndex + 1} of ${widget.questions.length}',
                          style: AppFonts.body(
                            fontSize: 16,
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
                    const SizedBox(height: 12),

                    // Compact Live Counters Badge Row
                    Row(
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
                    const SizedBox(height: 12),

                    // Progress bar
                    LinearProgressIndicator(
                      value: (widget.currentIndex + 1) / widget.questions.length,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 16),

                    // Horizontal Question Palette Bar
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        controller: _paletteScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.questions.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 6),
                        itemBuilder: (context, idx) {
                          final isCurrent = idx == widget.currentIndex;
                          final itemStatus = idx < widget.userAnswersList.length ? (widget.userAnswersList[idx]['status'] as String? ?? 'unvisited') : 'unvisited';
                          final isSkipped = itemStatus == 'skipped';
                          final isAnswered = itemStatus == 'answered';

                          Color pillColor = AppColors.grey.withValues(alpha: 0.1);
                          Color textColor = AppColors.textSecondary;
                          Border? border;

                          if (isCurrent) {
                            border = Border.all(color: AppColors.primary, width: 2);
                            pillColor = AppColors.primary.withValues(alpha: 0.15);
                            textColor = AppColors.primary;
                          } else if (isAnswered) {
                            pillColor = AppColors.success;
                            textColor = Colors.white;
                          } else if (isSkipped) {
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentQuestion.questionText,
                              style: AppFonts.heading(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Option Cards
                            _buildOptionCard('A', currentQuestion.optionA, widget.selectedOption, widget.onOptionSelected),
                            _buildOptionCard('B', currentQuestion.optionB, widget.selectedOption, widget.onOptionSelected),
                            _buildOptionCard('C', currentQuestion.optionC, widget.selectedOption, widget.onOptionSelected),
                            _buildOptionCard('D', currentQuestion.optionD, widget.selectedOption, widget.onOptionSelected),
                          ],
                        ),
                      ),
                    ),

                    // Next / Skip / Finish Action Button
                    SizedBox(
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SpringButton(
        isOutlined: true,
        backgroundColor: AppColors.card,
        borderColor: isSelected ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(16),
        depth: 3.0,
        height: 58.0,
        onPressed: () => onOptionSelected(key),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
