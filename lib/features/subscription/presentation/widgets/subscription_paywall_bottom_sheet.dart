import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_activation_page.dart';

class SubscriptionPaywallBottomSheet extends StatelessWidget {
  final String status;

  const SubscriptionPaywallBottomSheet({
    super.key,
    required this.status,
  });

  static Future<void> show(BuildContext context, {required String status}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionPaywallBottomSheet(status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    String badgeTag = 'PREMIUM ACCESS';
    String title = 'Unlock Battle Arena';
    String description = 'Subscribe to compete in live daily battles, track global rankings, and access full exam analytics.';
    String buttonText = 'View Subscription Plans';
    dynamic iconData = HugeIcons.strokeRoundedDiamond02;
    Color accentColor = AppColors.primary;

    if (status == 'expired') {
      badgeTag = 'MEMBERSHIP EXPIRED';
      title = 'Renew Your Subscription';
      description = 'Your previous plan has ended. Renew now to resume live battles and full platform access.';
      buttonText = 'Renew Subscription';
      iconData = HugeIcons.strokeRoundedAlertSquare;
      accentColor = AppColors.error;
    } else if (status == 'pending_verification' || status == 'pending') {
      badgeTag = 'VERIFICATION IN PROGRESS';
      title = 'Payment Under Review';
      description = 'Your payment details are being verified. Your access will be automatically unlocked once confirmed.';
      buttonText = 'Check Verification Status';
      iconData = HugeIcons.strokeRoundedClock01;
      accentColor = AppColors.accentYellow;
    } else if (status == 'cancelled') {
      badgeTag = 'PLAN CANCELLED';
      title = 'Reactivate Membership';
      description = 'Your subscription was cancelled. Reactivate your plan anytime to rejoin the arena.';
      buttonText = 'Reactivate Plan';
      iconData = HugeIcons.strokeRoundedCancel01;
      accentColor = AppColors.error;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              const SizedBox(height: 20),
              CustomContainer(
                color: AppColors.background,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: iconData,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeTag,
                              style: AppFonts.body(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppFonts.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SpringButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    SubscriptionActivationPage.route(),
                  );
                },
                child: Text(buttonText),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Dismiss',
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
