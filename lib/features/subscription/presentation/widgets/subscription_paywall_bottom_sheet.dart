import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_activation_page.dart';

class SubscriptionPaywallBottomSheet extends StatelessWidget {
  final String status;
  final String? customTitle;
  final String? customDescription;
  final String? customButtonText;

  const SubscriptionPaywallBottomSheet({
    super.key,
    required this.status,
    this.customTitle,
    this.customDescription,
    this.customButtonText,
  });

  static Future<void> show(
    BuildContext context, {
    required String status,
    String? customTitle,
    String? customDescription,
    String? customButtonText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionPaywallBottomSheet(
        status: status,
        customTitle: customTitle,
        customDescription: customDescription,
        customButtonText: customButtonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String badgeTag = 'PREMIUM MEMBERSHIP';
    String title = 'Unlock Premium Access';
    String description = 'This feature requires an active TargetAce membership. Verify your account status to gain full access.';
    String buttonText = 'Check Membership Status';
    dynamic iconData = HugeIcons.strokeRoundedDiamond02;
    Color accentColor = AppColors.primary;

    if (status == 'expired') {
      badgeTag = 'MEMBERSHIP INACTIVE';
      title = 'Membership Inactive';
      description = 'Your previous membership has ended. Verify your account status to resume live battles and full platform access.';
      buttonText = 'Check Status';
      iconData = HugeIcons.strokeRoundedAlertSquare;
      accentColor = AppColors.error;
    } else if (status == 'pending_verification' || status == 'pending') {
      badgeTag = 'VERIFICATION IN PROGRESS';
      title = 'Account Under Review';
      description = 'Your account details are being verified. Your access will be automatically unlocked once confirmed.';
      buttonText = 'Check Status';
      iconData = HugeIcons.strokeRoundedClock01;
      accentColor = AppColors.accentYellow;
    } else if (status == 'cancelled') {
      badgeTag = 'PLAN CANCELLED';
      title = 'Membership Cancelled';
      description = 'Your membership was cancelled. Contact support or check your account status to reactivate.';
      buttonText = 'Check Status';
      iconData = HugeIcons.strokeRoundedCancel01;
      accentColor = AppColors.error;
    }

    if (customTitle?.isNotEmpty ?? false) {
      title = customTitle!;
    }
    if (customDescription?.isNotEmpty ?? false) {
      description = customDescription!;
    }
    if (customButtonText?.isNotEmpty ?? false) {
      buttonText = customButtonText!;
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