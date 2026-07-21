import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/podium_widget.dart';
import 'package:target_ace/features/battle/presentation/pages/exam_review_page.dart';

class BattleScoreboardWidget extends StatelessWidget {
  final String examTitle;
  final double score;
  final int examRank;
  final int groupRank;
  final int globalRank;
  final List<Map<String, dynamic>> leaderboard;
  final bool isDisqualified;
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> userAnswersList;
  final VoidCallback onExit;

  const BattleScoreboardWidget({
    super.key,
    required this.examTitle,
    required this.score,
    required this.examRank,
    required this.groupRank,
    required this.globalRank,
    required this.leaderboard,
    required this.isDisqualified,
    required this.questions,
    required this.userAnswersList,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent back navigation
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top Trophy Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      isDisqualified
                          ? const HugeIcon(
                              icon: HugeIcons.strokeRoundedAlertCircle,
                              color: AppColors.error,
                              size: 56,
                            )
                          : const HugeIcon(
                              icon: HugeIcons.strokeRoundedCrown,
                              color: AppColors.accentYellow,
                              size: 56,
                            ),
                      const SizedBox(height: 12),
                      Text(
                        isDisqualified ? 'Disqualified!' : 'Battle Completed!',
                        style: AppFonts.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDisqualified ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        examTitle,
                        style: AppFonts.body(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomDivider.dotted(),
                      const SizedBox(height: 16),
                      
                      // 4-Metric Row (Score, Battle Rank, Group Rank, Global Rank)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricColumn('Score', isDisqualified ? 'DISQ' : '$score'),
                          _buildMetricColumn('Exam Rank', isDisqualified ? 'N/A' : '#$examRank'),
                          _buildMetricColumn('Group Rank', isDisqualified ? 'N/A' : '#$groupRank'),
                          _buildMetricColumn('Global Rank', isDisqualified ? 'N/A' : '#$globalRank'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Podium for Top 3
                if (leaderboard.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final items = List<Map<String, dynamic>?>.filled(3, null);
                      for (int i = 0; i < leaderboard.length && i < 3; i++) {
                        items[i] = leaderboard[i];
                      }

                      final podiumUsers = List<PodiumUser?>.generate(3, (index) {
                        final item = items[index];
                        if (item == null) return null;
                        return PodiumUser(
                          name: item['name'] as String? ?? 'Student',
                          avatarUrl: item['avatar_url'] as String? ?? '',
                          score: (item['score'] as num?)?.toDouble() ?? 0.0,
                          isMe: item['is_current_user'] as bool? ?? false,
                        );
                      });

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: PodiumWidget(
                          users: podiumUsers,
                          scoreSuffix: '/100',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Battle Leaderboard
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Battle Standings',
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final remainingItems = leaderboard.skip(3).toList();
                          if (remainingItems.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No more standings available',
                                  style: AppFonts.body(color: AppColors.textLight, fontSize: 13),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: remainingItems.length,
                            separatorBuilder: (context, index) => const Divider(color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final item = remainingItems[index];
                              final isMe = item['is_current_user'] as bool? ?? false;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.grey.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item['rank']}',
                                          style: AppFonts.body(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item['name'] as String,
                                        style: AppFonts.body(
                                          fontSize: 14,
                                          fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                                          color: isMe ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(item['score'] as num).round()}/100',
                                      style: AppFonts.body(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isMe ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      // If current user is not in the top 50, show an anchored card at the bottom of the list
                      Builder(
                        builder: (context) {
                          final int myIndex = leaderboard.indexWhere((u) => u['is_current_user'] == true);
                          final bool isOutsideTop50 = myIndex == -1 && examRank > 0;

                          if (isOutsideTop50) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(color: AppColors.divider, height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$examRank',
                                            style: AppFonts.body(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'You (Outside Top 50)',
                                          style: AppFonts.body(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${score.round()}/100',
                                        style: AppFonts.body(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Review Answers Button
                if (!isDisqualified && questions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(context, ExamReviewPage.route(
                            questions: questions,
                            userAnswers: userAnswersList,
                          ));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Review Answers',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Exit Button
                SizedBox(
                  width: double.infinity,
                  child: SpringButton(
                    backgroundColor: AppColors.primary,
                    shadowColor: Colors.black26,
                    onPressed: onExit,
                    child: Text(
                      'Back to Dashboard',
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppFonts.body(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
