import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class UpcomingBattlesSection extends StatelessWidget {
  final List<Map<String, dynamic>> upcomingExams;

  const UpcomingBattlesSection({
    super.key,
    required this.upcomingExams,
  });

  @override
  Widget build(BuildContext context) {
    if (upcomingExams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Upcoming Scheduled Battles',
            style: AppFonts.body(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingExams.length,
          itemBuilder: (context, index) {
            final exam = upcomingExams[index];
            final title = exam['title'] as String? ?? 'Scheduled Exam';
            final startTimeStr = exam['start_time'] as String?;
            String formattedDate = '';
            if (startTimeStr != null) {
              final dt = DateTime.parse(startTimeStr).toLocal();
              formattedDate = DateFormat('EEE, dd MMM - hh:mm a').format(dt);
            }

            return CustomContainer(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    color: AppColors.primary,
                    size: 20,
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
                        ),
                        Text(
                          formattedDate,
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
            );
          },
        ),
      ],
    );
  }
}
