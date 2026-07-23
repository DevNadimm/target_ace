import 'package:flutter/material.dart';
import 'package:target_ace/features/dashboard/presentation/pages/main_navigation_page.dart';

class SubscriptionNavigationHelper {
  SubscriptionNavigationHelper._();

  /// Routes to the main dashboard for all users (Subscription check currently bypassed)
  static void navigateByStatus(BuildContext context, String status) {
    Navigator.pushAndRemoveUntil(
      context,
      MainNavigationPage.route(),
      (_) => false,
    );
  }
}

