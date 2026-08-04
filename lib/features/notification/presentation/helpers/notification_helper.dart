import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';

class NotificationHelper {
  NotificationHelper._();

  /// Returns the corresponding HugeIcon for notification type
  static List<List<dynamic>> getTypeIcon(String type) {
    switch (type) {
      case 'exam_reminder':
        return HugeIcons.strokeRoundedClock01;
      case 'battle_invite':
        return HugeIcons.strokeRoundedCrown03;
      case 'streak_alert':
        return HugeIcons.strokeRoundedFire03;
      case 'subscription':
        return HugeIcons.strokeRoundedDiamond02;
      default:
        return HugeIcons.strokeRoundedNotification01;
    }
  }

  /// Returns the brand color for notification type
  static Color getTypeColor(String type) {
    switch (type) {
      case 'exam_reminder':
        return AppColors.accent;
      case 'battle_invite':
        return AppColors.labelGreen;
      case 'streak_alert':
        return AppColors.warning;
      case 'subscription':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  /// Returns user-friendly label for notification type
  static String getTypeLabel(String type) {
    switch (type) {
      case 'exam_reminder':
        return 'Exam Reminder';
      case 'battle_invite':
        return 'Battle Alert';
      case 'streak_alert':
        return 'Streak Update';
      case 'subscription':
        return 'Subscription';
      default:
        return 'Notification';
    }
  }
}
