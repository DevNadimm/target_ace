import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/home/presentation/widgets/home_podium_section.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_review_page.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class BattleScoreboardView extends StatelessWidget {
  final String examTitle;
  final double score;
  final int examRank;
  final int groupRank;
  final int globalRank;
  final List<LeaderboardEntryEntity> leaderboard;
  final bool isDisqualified;
  final List<QuestionEntity> questions;
  final List<Map<String, dynamic>> userAnswersList;
  final VoidCallback onExit;

  const BattleScoreboardView({
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
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Details
                Text(
                  examTitle,
                  style: AppFonts.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isDisqualified 
                      ? 'You were disqualified from the battle.' 
                      : 'Battle completed successfully! View your ranks below.',
                  style: AppFonts.body(
                    fontSize: 13,
                    color: isDisqualified ? AppColors.error : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Metrics Container
                CustomContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        isDisqualified ? 'DISQUALIFIED' : 'YOUR SCORE',
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDisqualified ? AppColors.error : AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isDisqualified ? '0' : '${score.toStringAsFixed(1)}%',
                        style: AppFonts.body(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: isDisqualified ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CustomDivider(height: 1),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricColumn('Score', '${score.toStringAsFixed(1)}/100'),
                          _buildMetricColumn('Exam Rank', '#$examRank'),
                          _buildMetricColumn('Group Rank', '#$groupRank'),
                          _buildMetricColumn('Global Rank', '#$globalRank'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // HomePodiumSection for Top 3
                if (leaderboard.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final items = List<LeaderboardEntryEntity?>.filled(3, null);
                      for (int i = 0; i < leaderboard.length && i < 3; i++) {
                        items[i] = leaderboard[i];
                      }

                      final podiumUsers = List<HomePodiumUser?>.generate(3, (index) {
                        final item = items[index];
                        if (item == null) return null;
                        return HomePodiumUser(
                          name: item.name,
                          avatarUrl: item.avatarUrl,
                          score: item.score,
                          isMe: item.isCurrentUser,
                        );
                      });

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: HomePodiumSection(
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
                              final isMe = item.isCurrentUser;

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
                                          '${item.rank}',
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
                                        item.name,
                                        style: AppFonts.body(
                                          fontSize: 14,
                                          fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                                          color: isMe ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${item.score.round()}/100',
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
                          final int myIndex = leaderboard.indexWhere((u) => u.isCurrentUser);
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
                                              color: Colors.white,
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
                      child: SpringButton.outlined(
                        borderColor: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        height: 52.0,
                        onPressed: () {
                          Navigator.push(context, BattleReviewPage.route(
                            questions: questions,
                            userAnswers: userAnswersList,
                          ));
                        },
                        child: Text(
                          'Review Answers',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                    onPressed: onExit,
                    child: Text(
                      'Back to Home',
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
          style: AppFonts.body(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}