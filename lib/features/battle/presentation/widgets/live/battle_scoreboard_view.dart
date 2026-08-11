import 'package:flutter/material.dart' hide BackButton;
import 'package:fl_chart/fl_chart.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/components/leaderboard_row.dart';
import 'package:target_ace/core/utils/helpers/helper_functions.dart';
import 'package:target_ace/features/home/presentation/widgets/home_podium_section.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/battle/presentation/bloc/battle/battle_bloc.dart';

class BattleScoreboardView extends StatelessWidget {
  final String examId;
  final String examTitle;
  final double score;
  final int examRank;
  final int groupRank;
  final int globalRank;
  final List<LeaderboardEntryEntity> leaderboard;
  final List<Map<String, dynamic>> userAnswersList;
  final VoidCallback onExit;

  const BattleScoreboardView({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.score,
    required this.examRank,
    required this.groupRank,
    required this.globalRank,
    required this.leaderboard,
    required this.userAnswersList,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final podiumItems = leaderboard.take(3).toList();
    final remainingItems = leaderboard.skip(3).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Scoreboard'), leading: BackButton()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildTriumphPlayerCard(context),
            ),
            if (podiumItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: _buildPodiumSection(podiumItems),
              ),
            if (remainingItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: remainingItems
                      .map((item) => _buildLayeredLeaderboardRow(item))
                      .toList(),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTriumphPlayerCard(BuildContext context) {
    int correct = userAnswersList
        .where((ans) => ans['is_correct'] == true)
        .length;
    int wrong = userAnswersList
        .where(
          (ans) =>
              ans['is_correct'] == false &&
              ans['selected'] != null &&
              ans['selected'].toString().isNotEmpty,
        )
        .length;
    int skipped = userAnswersList.length - correct - wrong;
    int total = userAnswersList.length;

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
                          HelperFunctions.padNumber(score.round()),
                          style: AppFonts.heading(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PTS',
                          style: AppFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Exam Rank: #$examRank',
                      style: AppFonts.body(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Group Rank: #$groupRank',
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
                                '${((correct / total) * 100).round()}%',
                                style: AppFonts.heading(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: ((correct / total) >= 0.7)
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
                        const SizedBox(height: 12),
                        _buildAccuracyLegendItem(
                          'Skipped',
                          '$skipped Qs',
                          AppColors.greyDark,
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 16),
          SpringButton(
            height: 39,
            depth: 3,
            onPressed: () {
              context.read<BattleBloc>().add(BattleReviewRequested(examId, userAnswersList));
            },
            child: Text('REVIEW ANSWERS'),
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

  Widget _buildPodiumSection(List<LeaderboardEntryEntity> topList) {
    final items = List<LeaderboardEntryEntity?>.filled(3, null);
    for (int i = 0; i < topList.length && i < 3; i++) {
      items[i] = topList[i];
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

    return HomePodiumSection(users: podiumUsers, scoreSuffix: ' pts');
  }

  Widget _buildLayeredLeaderboardRow(LeaderboardEntryEntity item) {
    final handle = '@${item.name.replaceAll(' ', '').toLowerCase()}';

    return LeaderboardRow(
      rank: item.rank,
      name: item.name,
      avatarUrl: item.avatarUrl,
      isMe: item.isCurrentUser,
      avatarSize: 36,
      rankWidth: 28,
      subtitle: Text(
        handle,
        style: AppFonts.body(
          fontSize: 11.5,
          color: AppColors.textLight,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.accentYellow,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${item.score.round()}',
            style: AppFonts.body(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
