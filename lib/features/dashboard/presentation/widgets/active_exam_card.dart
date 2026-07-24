import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';

/// Same visual language as [StreakCard]: CustomContainer as the base shell,
/// AppFonts/AppColors for typography + color, and a soft rounded pill for
/// the small "tag" label (goal / status).
class ActiveExamCard extends StatelessWidget {
  final DashboardExam? exam;
  final bool hasSubmitted;
  final String? userGoal;

  const ActiveExamCard({
    super.key,
    this.exam,
    this.hasSubmitted = false,
    this.userGoal,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPast = exam != null && now.isAfter(exam!.startTime.add(Duration(minutes: exam!.durationMinutes)));

    if (exam == null || isPast) {
      return _EmptyState(userGoal: userGoal);
    }

    return _ActiveState(
      exam: exam!,
      hasSubmitted: hasSubmitted,
      userGoal: userGoal,
    );
  }
}

/// Empty / no-live-exam state — mirrors StreakCard's use of CustomContainer
/// as a flat rounded shell with a tag pill up top.
class _EmptyState extends StatelessWidget {
  final String? userGoal;

  const _EmptyState({required this.userGoal});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "YOUR TARGET",
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
              if (userGoal != null && userGoal!.isNotEmpty)
                _TagPill(text: userGoal!, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "No live battle exams right now",
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Check back later for updates or review your preparation topics below.",
            style: AppFonts.body(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live / upcoming state — keeps the gradient + watermark + CTA button,
/// but sourced entirely from `exam` / `hasSubmitted` so it's fully stateless.
class _ActiveState extends StatelessWidget {
  final DashboardExam exam;
  final bool hasSubmitted;
  final String? userGoal;

  const _ActiveState({
    required this.exam,
    required this.hasSubmitted,
    required this.userGoal,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isLive = exam.isLive;
    final difference = exam.startTime.difference(now);
    final isWithin15Mins = difference.inSeconds <= 15 * 60;
    final isUpcoming = exam.startTime.isAfter(now);
    final canEnter = isLive || (isUpcoming && isWithin15Mins);
    final accentColor = isLive ? AppColors.labelGreen : AppColors.primary;

    String countdownText = '';
    if (isUpcoming) {
      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      countdownText = 'Battle in: $hours hrs : $minutes mins';
    }

    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLive ? "LIVE NOW" : "UPCOMING BATTLE",
                style: AppFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.0,
                ),
              ),
              if (userGoal != null && userGoal!.isNotEmpty)
                _TagPill(text: userGoal!, color: accentColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            exam.title,
            style: AppFonts.heading(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedClock01,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isLive
                    ? "Duration: ${exam.durationMinutes} minutes"
                    : countdownText,
                style: AppFonts.body(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: isUpcoming ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SpringButton(
            onPressed: (hasSubmitted || !canEnter)
                ? null
                : () => Navigator.push(context, LiveBattlePage.route()),
            child: Text(
              hasSubmitted
                  ? "Submitted"
                  : (isLive ? "Join Battle" : "Enter Waiting Room"),
            ),
          ),
          if (isUpcoming && !isWithin15Mins && !hasSubmitted) ...[
            const SizedBox(height: 8),
            Text(
              "Waiting room opens 15 mins before.",
              style: AppFonts.body(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small rounded "pill" label — same shape/spirit as the streak numbers
/// pill used elsewhere in the dashboard (10px h-padding, 4px v-padding,
/// fully rounded, 10% alpha fill of the accent color).
class _TagPill extends StatelessWidget {
  final String text;
  final Color color;

  const _TagPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppFonts.body(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
