import 'package:flutter/material.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/profile/presentation/widgets/selection_card.dart';
import 'package:target_ace/features/profile/presentation/widgets/step_header.dart';

class SelectionStepContainer<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<T> items;
  final String selectedId;
  final Set<String>? selectedIds;
  final bool isMultiSelect;
  final ValueChanged<T> onSelected;
  final String Function(T item) titleExtractor;
  final String? Function(T item)? trailingTextExtractor;
  final String? Function(T item)? imageExtractor;
  final String Function(T item)? idExtractor;
  final String? errorText;

  const SelectionStepContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    this.selectedId = '',
    this.selectedIds,
    this.isMultiSelect = false,
    required this.onSelected,
    required this.titleExtractor,
    this.trailingTextExtractor,
    this.imageExtractor,
    this.idExtractor,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(title: title, subtitle: subtitle),
        ...items.map((item) {
          final itemId = idExtractor != null ? idExtractor!(item) : titleExtractor(item);
          final isSelected = isMultiSelect
              ? (selectedIds?.contains(itemId) ?? false)
              : selectedId == itemId;

          final itemTitle = titleExtractor(item);
          final itemImage = imageExtractor?.call(item);

          return SelectionCard(
            title: itemTitle,
            image: itemImage,
            isSelected: isSelected,
            isMultiSelect: isMultiSelect,
            onTap: () => onSelected(item),
          );
        }),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppFonts.body(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
