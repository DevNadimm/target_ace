import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/notification/data/models/notification_model.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:intl/intl.dart';

class NotificationDetailPage extends StatelessWidget {
  static Route route(NotificationModel notification) => MaterialPageRoute(
        builder: (_) => NotificationDetailPage(notification: notification),
      );

  final NotificationModel notification;

  const NotificationDetailPage({super.key, required this.notification});

  String _formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (_) {
      return dateTime.toString();
    }
  }

  List<List<dynamic>> _getTypeIcon(String type) {
    switch (type) {
      case 'exam_reminder':
        return HugeIcons.strokeRoundedClock02;
      case 'battle_invite':
        return HugeIcons.strokeRoundedCrown;
      case 'streak_alert':
        return HugeIcons.strokeRoundedFire02;
      case 'subscription':
        return HugeIcons.strokeRoundedLegalDocument01;
      default:
        return HugeIcons.strokeRoundedNotification01;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'exam_reminder':
        return 'Exam Reminder';
      case 'battle_invite':
        return 'Battle Invite';
      case 'streak_alert':
        return 'Streak Alert';
      case 'subscription':
        return 'Subscription';
      default:
        return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeIcon = _getTypeIcon(notification.type);
    final typeLabel = _getTypeLabel(notification.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Details',
          style: AppFonts.heading(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: CustomContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HugeIcon(
                                      icon: typeIcon,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      typeLabel.toUpperCase(),
                                      style: AppFonts.body(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDateTime(notification.createdAt),
                                style: AppFonts.body(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            notification.title,
                            style: AppFonts.heading(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: AppColors.divider,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            notification.body,
                            style: AppFonts.body(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SpringButton(
                  backgroundColor: AppColors.error,
                  onPressed: () {
                    context.read<NotificationBloc>().add(DeleteSingleEvent(notification.id));
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete Notification',
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
