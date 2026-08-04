import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/info_row.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class GroupLockedView extends StatelessWidget {
  final String currentGroupTitle;
  final String lockExpiryDate;
  final int remainingDays;
  final VoidCallback onBack;

  const GroupLockedView({
    super.key,
    required this.currentGroupTitle,
    required this.lockExpiryDate,
    required this.remainingDays,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -20 * math.pi / 180,
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLocked,
                    color: AppColors.error,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Group Selection Locked',
              style: AppFonts.heading(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your group is locked for 30 days to keep competition fair and leaderboards consistent.',
              style: AppFonts.body(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Lock Details',
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            CustomContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  InfoRow(
                    icon: HugeIcons.strokeRoundedTarget01,
                    label: 'Current Battle Group',
                    value: currentGroupTitle.isNotEmpty
                        ? currentGroupTitle
                        : 'N/A',
                  ),
                  const CustomDivider.dotted(),
                  InfoRow(
                    icon: HugeIcons.strokeRoundedCalendar04,
                    label: 'Locked Until',
                    value: lockExpiryDate.isNotEmpty ? lockExpiryDate : 'N/A',
                  ),
                  const CustomDivider.dotted(),
                  InfoRow(
                    icon: HugeIcons.strokeRoundedClock01,
                    label: 'Days Remaining',
                    value: '$remainingDays days left',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Why is this locked?',
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            CustomContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  InfoRow(
                    icon: HugeIcons.strokeRoundedChampion,
                    label: 'Fair Competition',
                    value: 'Prevents rank manipulation by frequent group hopping.',
                  ),
                  const CustomDivider.dotted(),
                  InfoRow(
                    icon: HugeIcons.strokeRoundedChampion,
                    label: 'Leaderboard Integrity',
                    value: 'Ensures everyone competes fairly within their group.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SpringButton(
              width: double.infinity,
              backgroundColor: AppColors.primary,
              onPressed: onBack,
              child: const Text('GOT IT, GO BACK'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
