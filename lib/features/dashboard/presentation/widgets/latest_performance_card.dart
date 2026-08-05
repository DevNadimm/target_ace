import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/section_header.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/section_empty_state.dart';
import 'package:target_ace/core/utils/helpers/helper_functions.dart';

/// A single metric inside the [LatestPerformanceCard] (score, accuracy,
/// rank, time taken, etc). Kept generic so new metrics can be added later
/// without touching the widget itself.
class PerformanceStat {
  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final String? unit;

  /// Optional trend badge, e.g. "+27". Rendered in green with an up arrow
  /// when present — used for things like rank movement.
  final String? trend;

  const PerformanceStat({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
  });
}

/// Everything the card needs to render — exam context + the four stats.
/// Swap [LatestPerformanceModel.dummy] for real data once the repo/bloc
/// wiring for this section is in.
class LatestPerformanceModel {
  final String examTitle;
  final DateTime completedAt;
  final int score;
  final int scoreOutOf;
  final double accuracy;
  final int rank;
  final int totalParticipants;
  final Duration timeTaken;

  const LatestPerformanceModel({
    required this.examTitle,
    required this.completedAt,
    required this.score,
    required this.scoreOutOf,
    required this.accuracy,
    required this.rank,
    required this.totalParticipants,
    required this.timeTaken,
  });

  factory LatestPerformanceModel.dummy() {
    return LatestPerformanceModel(
      examTitle: 'BCS Daily Battle #4',
      completedAt: DateTime.now().subtract(const Duration(hours: 6)),
      score: 17,
      scoreOutOf: 100,
      accuracy: 0.58,
      rank: 654,
      totalParticipants: 1245,
      timeTaken: const Duration(minutes: 13, seconds: 42),
    );
  }

  List<PerformanceStat> get stats => [
    PerformanceStat(
      icon: HugeIcons.strokeRoundedStar,
      label: 'SCORE',
      value: '${HelperFunctions.padNumber(score)}/$scoreOutOf',
      unit: 'Points',
    ),
    PerformanceStat(
      icon: HugeIcons.strokeRoundedTarget02,
      label: 'ACCURACY',
      value: '${HelperFunctions.padNumber((accuracy * 100).round())}%',
      unit: 'Correct',
    ),
    PerformanceStat(
      icon: HugeIcons.strokeRoundedChampion,
      label: 'RANK',
      value: '#${HelperFunctions.padNumber(rank)}',
      unit: 'of ${HelperFunctions.padNumber(totalParticipants)}',
    ),
    PerformanceStat(
      icon: HugeIcons.strokeRoundedClock01,
      label: 'TIME TAKEN',
      value: _formatDuration(timeTaken),
      unit: 'Duration',
    ),
  ];

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

/// "Latest Performance" section — mirrors the visual language of
/// [ActiveExamCard] / [StreakCard]: same [CustomContainer] shell, same
/// dotted-divider + label-row header pattern as the leaderboard preview,
/// with a 4-up stat grid below.
class LatestPerformanceCard extends StatelessWidget {
  final LatestPerformanceModel? data;
  final VoidCallback? onViewAnalysis;

  const LatestPerformanceCard({
    super.key,
    required this.data,
    this.onViewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'LATEST PERFORMANCE',
            titleColor: AppColors.textPrimary,
            dotColor: AppColors.primary,
            trailingText: data?.examTitle,
            trailingColor: AppColors.textLight,
          ),
          if (data == null)
            const SectionEmptyState(
              message: 'No performance data available yet.\nParticipate in battles to see your stats here.',
            )
          else ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < data!.stats.length; i++)
                  Expanded(child: _StatCell(stat: data!.stats[i])),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final PerformanceStat stat;

  const _StatCell({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: stat.icon,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          stat.label,
          style: AppFonts.body(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            stat.value,
            style: AppFonts.heading(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
            maxLines: 1,
          ),
        ),
        if (stat.unit != null) ...[
          const SizedBox(height: 3),
          Text(
            stat.unit!,
            style: AppFonts.body(
              fontSize: 9.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
