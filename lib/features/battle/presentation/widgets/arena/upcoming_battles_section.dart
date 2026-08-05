import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/app_list_tile.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/section_header.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/section_empty_state.dart';

class UpcomingBattlesSection extends StatelessWidget {
  final List<BattleEntity> upcomingExams;

  const UpcomingBattlesSection({super.key, required this.upcomingExams});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'UPCOMING BATTLES',
              titleColor: AppColors.textPrimary,
              dotColor: AppColors.primary,
            ),
          ),
          if (upcomingExams.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: const SectionEmptyState(message: 'No upcoming battles have been scheduled yet. New battles will appear here soon.'),
            ),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 8),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final exam = upcomingExams[index];
              final title = exam.title.isNotEmpty
                  ? exam.title
                  : 'Scheduled Battle';
              final startTimeStr = exam.startTime;
              final formattedDate = DateFormatter.formatUpcomingTime(startTimeStr);

              return AppListTile(
                icon: HugeIcons.strokeRoundedCalendar04,
                title: title,
                subtitle: formattedDate,
              );
            },
            separatorBuilder: (context, index) => const CustomDivider.dotted(),
            itemCount: upcomingExams.length,
          ),
        ],
      ),
    );
  }
}
