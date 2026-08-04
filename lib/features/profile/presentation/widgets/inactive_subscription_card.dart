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
    String title = 'Get Premium Access';
    String description = 'Claim 7-day Free Trial or upgrade to unlock unlimited live battles and full analytics.';
    String buttonText = 'Claim Free Trial / Upgrade';

    if (status == 'expired') {
      title = 'Subscription Expired';
      description = 'Renew your plan to resume live battles and full platform analytics.';
      buttonText = 'Renew Now';
    } else if (status == 'pending_verification' || status == 'pending') {
      title = 'Verification Pending';
      description = 'Your payment is under review. Access will unlock once approved.';
      buttonText = 'Check Status';
    } else if (status == 'cancelled') {
      title = 'Plan Cancelled';
      description = 'Reactivate your premium subscription anytime to unlock full battle access.';
      buttonText = 'Reactivate';
    }

    return CustomContainer(
      onTap: () {
        Navigator.push(context, SubscriptionActivationPage.route());
      },
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
