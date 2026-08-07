import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/app_list_tile.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/section_header.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/section_empty_state.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_history_page.dart';
import 'package:target_ace/features/battle/presentation/widgets/arena/history_detail_bottom_sheet.dart';

class BattleHistorySection extends StatelessWidget {
  final List<UserSubmissionEntity> pastSubmissions;
  final Function(String examId, List<dynamic> answers) onReviewTap;

  const BattleHistorySection({
    super.key,
    required this.pastSubmissions,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastFive = pastSubmissions.take(5).toList();

    return CustomContainer(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'BATTLE HISTORY',
              titleColor: AppColors.textPrimary,
              dotColor: AppColors.primary,
              trailingText: 'See all',
              trailingColor: AppColors.primary,
              trailingFontWeight: FontWeight.w600,
              onTrailingTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BattleHistoryPage()),
              ),
            ),
          ),
          if (lastFive.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: const SectionEmptyState(message: 'Complete your first battle to see your results here.'),
            ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 8),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final sub = lastFive[index];
              final title = sub.examTitle;
              final score = sub.score;
              final totalParticipants = sub.totalParticipants > 0 ? sub.totalParticipants : 1;
              final rank = sub.rank > 0 ? sub.rank : 1;

              final String scoreDisplay = score == score.roundToDouble()
                  ? score.toStringAsFixed(0)
                  : score.toStringAsFixed(1);

              return AppListTile(
                onTap: () {
                  HistoryDetailBottomSheet.show(
                    context,
                    submission: sub,
                    onReviewTap: onReviewTap,
                  );
                },
                icon: HugeIcons.strokeRoundedChampion,
                title: title,
                subtitle: '$scoreDisplay pts  ●  Rank $rank/$totalParticipants',
              );
            },
            separatorBuilder: (context, index) => const CustomDivider.dotted(),
            itemCount: lastFive.length,
          ),
        ],
      ),
    );
  }
}

