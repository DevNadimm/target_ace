import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/auth/presentation/helpers/profile_setup_helpers.dart';

class GoalSelectionStep extends StatelessWidget {
  final List<Map<String, dynamic>> goals;
  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;

  const GoalSelectionStep({
    super.key,
    required this.goals,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Choose your Target',
          style: AppFonts.heading(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your primary goal. We will personalize your live battle exams and leaderboards accordingly.',
          style: AppFonts.body(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        if (goals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'No targets available at the moment.',
                style: AppFonts.body(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...goals.map((goal) {
            final goalId = goal['id'] as String? ?? '';
            final isSelected = selectedGoal == goalId;
            final goalColor = parseHexColor(goal['color_hex'] as String? ?? '#3B82F6');
            final goalIcon = mapIconToHugeIcon(goal['icon_name'] as String? ?? '');

            return CustomContainer(
              margin: EdgeInsets.symmetric(vertical: 6),
              onTap: () => onGoalSelected(goalId),
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.card,
              borderColor: isSelected ? AppColors.primary : AppColors.inputBorder,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: goalColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: HugeIcon(
                      icon: goalIcon,
                      color: goalColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal['title'] as String? ?? '',
                          style: AppFonts.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal['subtitle'] as String? ?? '',
                          style: AppFonts.body(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
