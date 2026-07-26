import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/features/notification/domain/entities/notification_entity.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:target_ace/features/notification/presentation/helpers/notification_helper.dart';

class NotificationDetailPage extends StatelessWidget {
  static Route route(NotificationEntity notification) => MaterialPageRoute(builder: (_) => NotificationDetailPage(notification: notification));

  final NotificationEntity notification;

  const NotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final typeIcon = NotificationHelper.getTypeIcon(notification.type);
    final typeLabel = NotificationHelper.getTypeLabel(notification.type);
    final typeColor = NotificationHelper.getTypeColor(notification.type);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CustomIconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02),
              onTap: () {
                AppConfirmationDialog.show(
                  context,
                  title: 'Delete Notification',
                  message: 'Are you sure you want to delete this notification?',
                  confirmText: 'Delete',
                  cancelText: 'Cancel',
                  isDestructive: true,
                  onConfirm: () {
                    context.read<NotificationBloc>().add(
                      DeleteSingleEvent(notification.id),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 70, 24, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [typeColor, typeColor.withValues(alpha: 0.75)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: typeIcon,
                        color: AppColors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        typeLabel.toUpperCase(),
                        style: AppFonts.body(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notification.title,
                  style: AppFonts.heading(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormatter.readableWithTime(notification.createdAt),
                  style: AppFonts.body(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  child: Text(
                    notification.body,
                    style: AppFonts.body(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
