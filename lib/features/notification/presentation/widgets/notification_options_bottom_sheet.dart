import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/app_list_tile.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';

class NotificationOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onDeleteAll;

  const NotificationOptionsBottomSheet({
    super.key,
    required this.onDeleteAll,
  });

  static void show(BuildContext context, {required VoidCallback onDeleteAll}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<NotificationBloc>(),
          child: NotificationOptionsBottomSheet(onDeleteAll: onDeleteAll),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification Options',
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomContainer(
              onTap: () {
                Navigator.pop(context);
                context.read<NotificationBloc>().add(MarkAllReadEvent());
              },
              padding: EdgeInsets.zero,
              child: IgnorePointer(
                child: AppListTile(
                  title: 'Read All',
                  subtitle: 'Instantly mark everything as read',
                  onTap: () {},
                  icon: HugeIcons.strokeRoundedCheckmarkSquare02,
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomContainer(
              onTap: () {
                Navigator.pop(context);
                onDeleteAll();
              },
              padding: EdgeInsets.zero,
              child: IgnorePointer(
                child: AppListTile(
                  title: 'Clear History',
                  subtitle: 'Remove all your notifications from the list',
                  onTap: () {},
                  icon: HugeIcons.strokeRoundedDelete02,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}