import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class ExplanationCard extends StatelessWidget {
  final String explanation;

  const ExplanationCard({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Color.alphaBlend(AppColors.info.withValues(alpha: 0.1), AppColors.background),
      borderColor: AppColors.info.withValues(alpha: 0.8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedInformationCircle,
                color: AppColors.info,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'à¦¬à§à¦¯à¦¾à¦–à§à¦¯à¦¾ (Explanation)',
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: AppFonts.body(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}