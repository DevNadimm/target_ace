import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class SectionEmptyState extends StatelessWidget {
  final String message;
  final List<List<dynamic>>? icon;

  const SectionEmptyState({
    super.key,
    required this.message,
    this.icon = HugeIcons.strokeRoundedInvestigation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon ?? HugeIcons.strokeRoundedInvestigation,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppFonts.body(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
