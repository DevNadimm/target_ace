import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/features/battle/presentation/pages/exam_leaderboard_page.dart';
import 'package:target_ace/features/battle/presentation/pages/history_page.dart';

class RecentExamHistorySection extends StatelessWidget {
  final List<Map<String, dynamic>> pastSubmissions;
  final Function(String examId, List<dynamic> answers) onReviewTap;

  const RecentExamHistorySection({
    super.key,
    required this.pastSubmissions,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Recent Exam History',
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (pastSubmissions.length > 5)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  );
                },
                child: Text(
                  'See All',
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        _buildHistoryList(context),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    if (pastSubmissions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: CustomContainer(
          child: EmptyStateWidget(
            icon: SvgPicture.asset(
              Assets.archiveOutlined,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryLight,
                BlendMode.srcIn,
              ),
              height: 70,
            ),
            title: 'No History Yet',
            message: 'Complete your first battle to start building your history.',
          ),
        ),
      );
    }

    final lastFiveSubmissions = pastSubmissions.take(5).toList();

    return Column(
      children: lastFiveSubmissions.map((sub) {
        final title = sub['exam_title'] as String? ?? 'Exam';
        final score = (sub['score'] as num?)?.toDouble() ?? 0.0;
        final examId = (sub['exam_id'] as String?) ?? '';
        final answersList = sub['answers'] as List<dynamic>? ?? [];
        final correctCount = sub['correct_count'] as int? ?? 0;
        final wrongCount = sub['wrong_count'] as int? ?? 0;
        final totalParticipants = sub['total_participants'] as int? ?? 1;
        final rank = sub['exam_rank'] as int?;

        final submittedAtStr = sub['submitted_at'] as String?;
        String formattedDateTime = 'N/A';
        if (submittedAtStr != null) {
          final dt = DateTime.parse(submittedAtStr).toLocal();
          formattedDateTime = DateFormat('dd MMM, hh:mm a').format(dt);
        }

        final timeTakenSecs = sub['time_taken_seconds'] as int? ?? 0;
        final hours = timeTakenSecs ~/ 3600;
        final timeMins = (timeTakenSecs % 3600) ~/ 60;
        final timeSecs = timeTakenSecs % 60;

        String formattedDuration;
        if (hours > 0) {
          final hrsStr = hours.toString().padLeft(2, '0');
          final minsStr = timeMins.toString().padLeft(2, '0');
          formattedDuration = '$hrsStr hrs $minsStr mins';
        } else if (timeMins > 0) {
          final minsStr = timeMins.toString().padLeft(2, '0');
          final secsStr = timeSecs.toString().padLeft(2, '0');
          formattedDuration = '$minsStr mins $secsStr secs';
        } else if (timeSecs > 0) {
          final secsStr = timeSecs.toString().padLeft(2, '0');
          formattedDuration = '$secsStr secs';
        } else {
          formattedDuration = '00 mins';
        }

        return CustomContainer(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    formattedDateTime,
                    style: AppFonts.body(
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedAward01, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Rank #${rank ?? '-'} / $totalParticipants',
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedClock02, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          formattedDuration,
                          style: AppFonts.body(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const CustomDivider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score',
                            style: AppFonts.body(fontSize: 10, color: AppColors.textLight),
                          ),
                          Text(
                            score.toStringAsFixed(2),
                            style: AppFonts.body(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$correctCount',
                            style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.cancel_outlined, color: AppColors.error, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$wrongCount',
                            style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.inputBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () {
                          if (examId.isNotEmpty) {
                            onReviewTap(examId, answersList);
                          }
                        },
                        child: Text(
                          'Review',
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: () {
                          if (examId.isNotEmpty) {
                            Navigator.push(context, ExamLeaderboardPage.route(examId: examId, examTitle: title));
                          }
                        },
                        child: Text(
                          'Leaderboard',
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
