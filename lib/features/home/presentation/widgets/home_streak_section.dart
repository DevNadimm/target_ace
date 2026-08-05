import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/utils/helpers/helper_functions.dart';

class HomeStreakSection extends StatelessWidget {
  final int streakCount;
  final int highestStreak;
  final List<String> weeklyActiveDays;

  const HomeStreakSection({
    super.key,
    required this.streakCount,
    required this.highestStreak,
    this.weeklyActiveDays = const [],
  });

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    final int targetCount = highestStreak > streakCount
        ? highestStreak
        : (streakCount == 0 ? 7 : (streakCount < 7 ? 7 : ((streakCount ~/ 7) + 1) * 7));

    final double progressRatio = targetCount > 0
        ? (streakCount / targetCount).clamp(0.0, 1.0)
        : 0.0;

    final int activeDaysThisWeek = streakCount >= 7
        ? 7
        : (streakCount > 0 ? streakCount : 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomContainer(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.streakFlame,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(height: 8),
              Text(
                "$streakCount ${streakCount == 1 ? 'day' : 'days'}",
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Daily streak",
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    HelperFunctions.padNumber(streakCount),
                    style: AppFonts.heading(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    " / ${HelperFunctions.padNumber(targetCount)}",
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final fillWidth = (maxWidth * progressRatio).clamp(
                    progressRatio > 0 ? 12.0 : 0.0,
                    maxWidth,
                  );
                  return Stack(
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      if (fillWidth > 0)
                        Container(
                          height: 14,
                          width: fillWidth,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.2),
                                blurRadius: 14,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              CustomContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final dayName = daysOfWeek[index];
                    final isCompleted = weeklyActiveDays.isNotEmpty
                        ? weeklyActiveDays.contains(dayName)
                        : index < activeDaysThisWeek;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.card
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: isCompleted
                              ? Image.asset(
                                  Assets.streakFlame,
                                  fit: BoxFit.cover,
                                  colorBlendMode: BlendMode.srcIn,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayName,
                          style: AppFonts.body(
                            fontSize: 9.5,
                            fontWeight: isCompleted
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}