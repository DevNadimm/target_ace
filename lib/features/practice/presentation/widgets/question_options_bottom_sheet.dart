import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/components/app_list_tile.dart';
import 'package:target_ace/core/components/custom_container.dart';

class QuestionOptionsBottomSheet extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onReportError;

  const QuestionOptionsBottomSheet({
    super.key,
    required this.isBookmarked,
    this.onToggleBookmark,
    this.onReportError,
  });

  static void show(
    BuildContext context, {
    required bool isBookmarked,
    VoidCallback? onToggleBookmark,
    VoidCallback? onReportError,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return QuestionOptionsBottomSheet(
          isBookmarked: isBookmarked,
          onToggleBookmark: onToggleBookmark,
          onReportError: onReportError,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Center(
              child: Container(
                height: 5,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question Options',
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (onToggleBookmark != null) ...[
              CustomContainer(
                onTap: () {
                  Navigator.pop(context);
                  onToggleBookmark!();
                },
                padding: EdgeInsets.zero,
                child: IgnorePointer(
                  child: AppListTile(
                    title: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                    subtitle: isBookmarked ? 'Remove this question from saved list' : 'Save this question for later review',
                    onTap: () {},
                    icon: isBookmarked
                        ? HugeIcons.strokeRoundedBookmark02
                        : HugeIcons.strokeRoundedBookmark01,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (onReportError != null) ...[
              CustomContainer(
                onTap: () {
                  Navigator.pop(context);
                  onReportError!();
                },
                padding: EdgeInsets.zero,
                child: IgnorePointer(
                  child: AppListTile(
                    title: 'Report Error',
                    subtitle: 'Let us know if there\'s a mistake',
                    onTap: () {},
                    icon: HugeIcons.strokeRoundedFlag02,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}