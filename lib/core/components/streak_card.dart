import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class StreakCard extends StatelessWidget {
  final int streakCount;
  final int highestStreak;

  const StreakCard({
    super.key,
    required this.streakCount,
    required this.highestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CURRENT STREAK",
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$streakCount",
                        style: AppFonts.heading(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "🔥",
                        style: AppFonts.heading(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Day${streakCount == 1 ? "" : "s"} Streak",
                    style: AppFonts.body(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Lottie.asset(
                  Assets.flameAnim,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const HugeIcon(
                      icon: HugeIcons.strokeRoundedFire,
                      color: AppColors.primary,
                      size: 96,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < streakCount;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == 6 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < streakCount;
              final dayNum = index + 1;
              return _buildCalendarDayBlock(dayNum, isCompleted);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDayBlock(int day, bool isCompleted) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.divider.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 3,
              height: 7,
              decoration: BoxDecoration(
                color: isCompleted ? activeColor : AppColors.textLight.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 3,
              height: 7,
              decoration: BoxDecoration(
                color: isCompleted ? activeColor : AppColors.textLight.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -3),
          child: Container(
            width: 36,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted ? activeColor.withValues(alpha: 0.5) : inactiveColor,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isCompleted ? activeColor : AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "$day",
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? activeColor : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
