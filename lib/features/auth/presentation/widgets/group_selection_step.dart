import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class GroupSelectionStep extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  final String selectedGroup;
  final ValueChanged<String> onGroupSelected;
  final List<List<dynamic>> Function(String iconName) mapIcon;

  const GroupSelectionStep({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onGroupSelected,
    required this.mapIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Select your Group',
          style: AppFonts.heading(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your scientific or academic stream. You will compete with peers studying the same subjects.',
          style: AppFonts.body(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        if (groups.isEmpty)
          CustomContainer(
            margin: const EdgeInsets.symmetric(vertical: 6),
            onTap: () => onGroupSelected(selectedGroup),
            color: AppColors.primary.withValues(alpha: 0.1),
            borderColor: AppColors.primary,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HugeIcon(
                    icon: mapIcon('target01'),
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General Stream',
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Standard combined group battle arena for all applicants.',
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
          )
        else
          ...groups.map((group) {
            final groupId = group['id'] as String? ?? '';
            final isSelected = selectedGroup == groupId;
            final groupIcon = mapIcon(group['icon_name'] as String? ?? '');

            return CustomContainer(
              margin: const EdgeInsets.symmetric(vertical: 6),
              onTap: () => onGroupSelected(groupId),
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.card,
              borderColor: isSelected ? AppColors.primary : AppColors.inputBorder,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: HugeIcon(
                      icon: groupIcon,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group['title'] as String? ?? '',
                          style: AppFonts.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (group['subtitle'] != null &&
                            (group['subtitle'] as String).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            group['subtitle'] as String,
                            style: AppFonts.body(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
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
