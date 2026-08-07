import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';

class BattleHistoryCard extends StatelessWidget {
  final UserSubmissionEntity submission;
  final VoidCallback onTap;

  const BattleHistoryCard({
    super.key,
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = submission.examTitle;
    final score = submission.score;
    final totalParticipants = submission.totalParticipants > 0 ? submission.totalParticipants : 1;
    final rank = submission.rank > 0 ? submission.rank : 1;

    final String scoreDisplay = score == score.roundToDouble()
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);

    return CustomContainer(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedChampion,
                color: AppColors.primary,
                size: 20,
              ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '$scoreDisplay pts  ●  Rank $rank/$totalParticipants',
                  style: AppFonts.body(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.textLight,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
