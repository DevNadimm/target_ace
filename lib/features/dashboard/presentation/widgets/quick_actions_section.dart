import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/app_list_tile.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/section_header.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/features/practice/presentation/pages/subject_list_page.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_page.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomContainer(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SectionHeader(
                title: 'PREPARATION & PRACTICE',
                titleColor: AppColors.textPrimary,
                dotColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            AppListTile(
              icon: HugeIcons.strokeRoundedBookOpen01,
              title: "Subject Practice",
              subtitle: "Practice by subjects",

              onTap: () => Navigator.push(context, SubjectListPage.route(showBackButton: true)),
            ),
            const CustomDivider.dotted(),
            AppListTile(
              icon: HugeIcons.strokeRoundedChampion,
              title: "Leaderboard",
              subtitle: "See your ranking",

              onTap: () {
                AppNotifier.showSnackBar(
                  context,
                  "Leaderboard will be updated after the match.",
                  type: MessageType.info,
                );
              },
            ),
            const CustomDivider.dotted(),
            AppListTile(
              icon: HugeIcons.strokeRoundedDiamond02,
              title: "Subscription",
              subtitle: "Manage your plan",

              onTap: () {
                AppNotifier.showSnackBar(
                  context,
                  "Subscription Paywall coming soon.",
                  type: MessageType.info,
                );
              },
            ),
            const CustomDivider.dotted(),
            AppListTile(
              icon: HugeIcons.strokeRoundedUser03,
              title: "My Profile",
              subtitle: "View your profile",

              onTap: () => Navigator.push(context, ProfilePage.route()),
            ),
          ],
        ),
      ),
    );
  }
}

