import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/presentation/bloc/session/practice_session_cubit.dart';
import 'package:target_ace/features/practice/presentation/pages/practice_session_page.dart';
import 'package:target_ace/features/practice/presentation/pages/review_answers_page.dart';

class PracticeResultPage extends StatelessWidget {
  final SubjectEntity subject;

  const PracticeResultPage({super.key, required this.subject});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Practice Complete'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: GradientBackground(
          child: BlocBuilder<PracticeSessionCubit, PracticeSessionState>(
            builder: (context, state) {
              final cubit = context.read<PracticeSessionCubit>();
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: _buildResultCard(context, cubit),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SpringButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              backgroundColor: AppColors.card,
                              shadowColor: AppColors.grey,
                              child: Text(
                                'TOPICS',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SpringButton(
                              onPressed: () {
                                cubit.resetSession();
                                Navigator.pushReplacement(
                                  context,
                                  PracticeSessionPage.route(
                                    subject: subject,
                                    topicId: state.selectedTopicId,
                                  ),
                                );
                              },
                              child: Text(
                                'PRACTICE AGAIN',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, PracticeSessionCubit cubit) {
    final total = cubit.totalSessionQuestions;
    final correct = cubit.correctAnswersCount;
    final wrong = cubit.wrongAnswersCount;
    final accuracy = cubit.sessionAccuracy;
    final time = cubit.sessionDuration;
    final skipped = total - correct - wrong;

    return CustomContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${accuracy.round()}',
                          style: AppFonts.heading(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '%',
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Time Spent: ${_formatDuration(time)}',
                      style: AppFonts.body(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Questions: $total',
                      style: AppFonts.body(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardAlt,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(4, 5),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.04),
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 32,
                              startDegreeOffset: -90,
                              sections: [
                                if (correct > 0)
                                  PieChartSectionData(
                                    color: AppColors.labelGreen,
                                    value: correct.toDouble(),
                                    title: '',
                                    radius: 15,
                                  ),
                                if (wrong > 0)
                                  PieChartSectionData(
                                    color: AppColors.error,
                                    value: wrong.toDouble(),
                                    title: '',
                                    radius: 15,
                                  ),
                                if (skipped > 0)
                                  PieChartSectionData(
                                    color: Colors.grey,
                                    value: skipped.toDouble(),
                                    title: '',
                                    radius: 15,
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${accuracy.round()}%',
                                style: AppFonts.heading(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: (accuracy >= 70)
                                      ? AppColors.labelGreen
                                      : Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Accuracy',
                                style: AppFonts.body(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAccuracyLegendItem(
                          'Correct',
                          '$correct Qs',
                          AppColors.labelGreen,
                        ),
                        const SizedBox(height: 12),
                        _buildAccuracyLegendItem(
                          'Wrong',
                          '$wrong Qs',
                          AppColors.error,
                        ),
                        if (skipped > 0) ...[
                          const SizedBox(height: 12),
                          _buildAccuracyLegendItem(
                            'Skipped',
                            '$skipped Qs',
                            AppColors.greyDark,
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SpringButton(
            height: 39,
            depth: 3,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: ReviewAnswersPage(subject: subject),
                  ),
                ),
              );
            },
            child: const Text('REVIEW ANSWERS'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.body(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppFonts.body(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

