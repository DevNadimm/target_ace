import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_activation_page.dart';

class InactiveSubscriptionCard extends StatelessWidget {
  final String status;

  const InactiveSubscriptionCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String title = 'Premium Membership';
    String description = 'Unlock exclusive features and take your preparation to the next level with a premium membership.';
    String buttonText = 'VIEW MEMBERSHIP STATUS';

    if (status == 'expired') {
      title = 'Membership Inactive';
      description = 'Your membership is currently inactive. Verify your account status to resume.';
      buttonText = 'CHECK STATUS';
    } else if (status == 'pending_verification' || status == 'pending') {
      title = 'Verification Pending';
      description = 'Your account is being reviewed. Status will update once approved.';
      buttonText = 'CHECK STATUS';
    } else if (status == 'cancelled') {
      title = 'Membership Cancelled';
      description = 'Your membership was cancelled. Contact support or check your account status anytime.';
      buttonText = 'CHECK STATUS';
    }

    return CustomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppFonts.body(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SpringButton(
            height: 39,
            depth: 3,
            onPressed: () {
              Navigator.push(context, SubscriptionActivationPage.route());
            },
            child: Center(
              child: Text(
                buttonText,
                style: AppFonts.body(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}