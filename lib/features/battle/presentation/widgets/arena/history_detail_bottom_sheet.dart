import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_leaderboard_page.dart';

class HistoryDetailBottomSheet extends StatelessWidget {
  final UserSubmissionEntity submission;
  final Function(String examId, List<dynamic> answers) onReviewTap;

  const HistoryDetailBottomSheet({
    super.key,
    required this.submission,
    required this.onReviewTap,
  });

  static void show(
    BuildContext context, {
    required UserSubmissionEntity submission,
    required Function(String examId, List<dynamic> answers) onReviewTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryDetailBottomSheet(
        submission: submission,
        onReviewTap: onReviewTap,
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return 'N/A';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0 && s > 0) return '${m}m ${s}s';
    if (m > 0) return '${m}m';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final title = submission.examTitle;
    final score = submission.score;
    final examId = submission.examId;
    final answersList = submission.answers;
    final totalParticipants = submission.totalParticipants > 0
        ? submission.totalParticipants
        : 1;
    final rank = submission.rank > 0 ? submission.rank : 1;

    String formattedDateTime = 'N/A';
    if (submission.completedAt.isNotEmpty) {
      final dt = DateTime.parse(submission.completedAt).toLocal();
      formattedDateTime = DateFormat('dd MMM yyyy  ●  hh:mm a').format(dt);
    }

    final String scoreDisplay = score == score.roundToDouble()
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);

    final Color rankColor = score >= 80
        ? AppColors
              .success // Green (Success)
        : score >= 50
        ? AppColors
              .primary // Orange (Average)
        : score >= 30
        ? AppColors
              .accentYellow // Yellow (Below average)
        : AppColors.error; // Red (Ekdom kharap)

    final totalQuestions =
        submission.correctCount +
        submission.wrongCount +
        submission.unansweredCount;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Center(
                child: Container(
                  height: 5,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomContainer(
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                scoreDisplay,
                                style: AppFonts.heading(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: rankColor,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(width: 1),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '/100',
                                  style: AppFonts.heading(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: rankColor.withValues(alpha: 0.8),
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'PTS',
                            style: AppFonts.body(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: rankColor.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDateTime,
                            style: AppFonts.body(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Rank #$rank out of $totalParticipants participants  ●  $totalQuestions questions',
                style: AppFonts.body(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              Text(
                score >= 80
                    ? 'Outstanding performance! You achieved an excellent score in this battle.'
                    : score >= 50
                    ? 'Good effort! Keep practicing to push your score even higher next time.'
                    : score >= 30
                    ? 'Keep practicing! Review your answers and try again to improve your score.'
                    : 'Don\'t give up! Review your mistakes carefully and keep practicing to bounce back.',
                style: AppFonts.body(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatRow(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: AppColors.textSecondary,
                label: 'Correct',
                value: '${submission.correctCount}',
              ),
              const SizedBox(height: 6),
              _buildStatRow(
                icon: HugeIcons.strokeRoundedCancel01,
                color: AppColors.textSecondary,
                label: 'Wrong',
                value: '${submission.wrongCount}',
              ),
              const SizedBox(height: 6),
              _buildStatRow(
                icon: HugeIcons.strokeRoundedMinusSign,
                color: AppColors.textSecondary,
                label: 'Skipped',
                value: '${submission.unansweredCount}',
              ),
              const SizedBox(height: 6),
              _buildStatRow(
                icon: HugeIcons.strokeRoundedClock01,
                color: AppColors.textSecondary,
                label: 'Time Taken',
                value: _formatTime(submission.timeTakenSeconds),
              ),
              if (submission.disqualified) ...[
                const SizedBox(height: 6),
                _buildStatRow(
                  icon: HugeIcons.strokeRoundedAlert02,
                  color: AppColors.textSecondary,
                  label: 'Status',
                  value: 'Disqualified',
                  valueColor: AppColors.error,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SpringButton(
                      onPressed: examId.isNotEmpty
                          ? () {
                              Navigator.pop(context);
                              onReviewTap(examId, answersList);
                            }
                          : null,
                      child: const Text('REVIEW'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SpringButton.outlined(
                      onPressed: examId.isNotEmpty
                          ? () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                BattleLeaderboardPage.route(
                                  examId: examId,
                                  examTitle: title,
                                ),
                              );
                            }
                          : null,
                      child: const Text('LEADERBOARD'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required List<List<dynamic>> icon,
    required Color color,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        HugeIcon(icon: icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppFonts.body(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

