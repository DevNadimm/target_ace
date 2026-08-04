import 'package:flutter/material.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';

class TopicFilterChips extends StatelessWidget {
  final List<TopicEntity> topics;
  final String? selectedTopicId;
  final ValueChanged<String?> onTopicChanged;

  const TopicFilterChips({
    super.key,
    required this.topics,
    required this.selectedTopicId,
    required this.onTopicChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllSelected = selectedTopicId == null;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          ChoiceChip(
            label: Text(
              'All Chapters', 
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: isAllSelected ? FontWeight.bold : FontWeight.normal,
                color: isAllSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: isAllSelected,
            onSelected: (_) => onTopicChanged(null),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.card,
            showCheckmark: false,
            side: BorderSide(
              color: isAllSelected ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          ...topics.map((topic) {
            final isSelected = selectedTopicId == topic.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  topic.name, 
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onTopicChanged(topic.id),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.card,
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
