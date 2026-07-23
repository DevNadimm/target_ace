import 'package:flutter/material.dart';
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
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
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
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        title,
                        style: AppFonts.heading(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: AppFonts.body(
                      fontSize: 11,
                      color: AppColors.textSecondary,
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
