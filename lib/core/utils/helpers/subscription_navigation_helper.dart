import 'package:flutter/material.dart';
import 'package:target_ace/features/dashboard/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_activation_page.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_cancelled_page.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_expired_page.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_pending_page.dart';

class SubscriptionNavigationHelper {
  SubscriptionNavigationHelper._();

  /// Routes to the appropriate screen depending on subscription status
  static void navigateByStatus(BuildContext context, String status) {
    switch (status) {
      case 'active':
      case 'trial':
        Navigator.pushAndRemoveUntil(
          context,
          MainNavigationPage.route(),
          (_) => false,
        );
        break;
      case 'pending_verification':
        Navigator.pushAndRemoveUntil(
          context,
          SubscriptionPendingPage.route(),
          (_) => false,
        );
        break;
      case 'expired':
        Navigator.pushAndRemoveUntil(
          context,
          SubscriptionExpiredPage.route(),
          (_) => false,
        );
        break;
      case 'cancelled':
        Navigator.pushAndRemoveUntil(
          context,
          SubscriptionCancelledPage.route(),
          (_) => false,
        );
        break;
      case 'none':
      default:
        Navigator.pushAndRemoveUntil(
          context,
          SubscriptionActivationPage.route(),
          (_) => false,
        );
        break;
    }
  }
}

