import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:target_ace/features/notification/presentation/pages/notification_detail_page.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const NotificationPage());

  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(dateTime);
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'exam_reminder':
        return AppColors.primary;
      case 'battle_invite':
        return AppColors.success;
      case 'streak_alert':
        return AppColors.warning;
      case 'subscription':
        return AppColors.info;
      default:
        return AppColors.primaryLight;
    }
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Notifications',
          style: AppFonts.heading(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: AppFonts.body(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppFonts.body(fontSize: 14, color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(DeleteAllEvent());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Clear All', style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppFonts.heading(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(child: Loader());
              }

              if (state is NotificationError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedAlertCircle,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: AppFonts.body(fontSize: 13, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _fetchNotifications,
                          child: Text(
                            'Try Again',
                            style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is NotificationLoaded) {
                final list = state.notifications;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedNotification01,
                            color: AppColors.textLight.withValues(alpha: 0.3),
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No notifications yet',
                          style: AppFonts.body(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'ll let you know when something important happens.',
                          style: AppFonts.body(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final hasUnread = list.any((item) => !item.isRead);

                return RefreshIndicator(
                  onRefresh: () async {
                    _fetchNotifications();
                  },
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hasUnread)
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                label: Text(
                                  'Mark all read',
                                  style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                onPressed: () {
                                  context.read<NotificationBloc>().add(MarkAllReadEvent());
                                },
                              )
                            else
                              const SizedBox.shrink(),
                            TextButton.icon(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                color: AppColors.error,
                                size: 16,
                              ),
                              label: Text(
                                'Clear all',
                                style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error),
                              ),
                              onPressed: _showDeleteAllConfirmation,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final itemColor = _getTypeColor(item.type);
                            final itemIcon = _getTypeIcon(item.type);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () {
                                  if (!item.isRead) {
                                    context.read<NotificationBloc>().add(MarkReadEvent(item.id));
                                  }
                                  Navigator.push(context, NotificationDetailPage.route(item));
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: CustomContainer(
                                  color: item.isRead ? AppColors.cardAlt : AppColors.card,
                                  borderColor: item.isRead
                                      ? AppColors.divider
                                      : AppColors.primary.withValues(alpha: 0.4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: itemColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: HugeIcon(
                                          icon: itemIcon,
                                          color: itemColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: AppFonts.body(
                                                      fontSize: 14,
                                                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                                      color: item.isRead ? AppColors.textPrimary.withValues(alpha: 0.8) : AppColors.textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (!item.isRead)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.body,
                                              style: AppFonts.body(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                                height: 1.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _timeAgo(item.createdAt),
                                              style: AppFonts.body(
                                                fontSize: 10,
                                                color: AppColors.textLight,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: HugeIcon(
                                          icon: HugeIcons.strokeRoundedDelete02,
                                          color: AppColors.textLight,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          context.read<NotificationBloc>().add(DeleteSingleEvent(item.id));
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
