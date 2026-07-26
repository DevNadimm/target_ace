import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/features/notification/domain/entities/notification_entity.dart';
import 'package:target_ace/features/notification/presentation/helpers/notification_helper.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = NotificationHelper.getTypeColor(item.type);
    final itemIcon = NotificationHelper.getTypeIcon(item.type);
    final emphasis = item.isRead ? 0.8 : 1.0;

    return CustomContainer(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: itemColor.withValues(alpha: 0.15 * emphasis),
              shape: BoxShape.circle,
              border: Border.all(
                color: itemColor.withValues(alpha: 0.30 * emphasis),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: HugeIcon(
                    icon: itemIcon,
                    color: itemColor.withValues(alpha: emphasis),
                    size: 20,
                  ),
                ),
                if (!item.isRead) ...[
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                    color: item.isRead
                        ? AppColors.textPrimary.withValues(alpha: emphasis)
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  item.body,
                  style: AppFonts.body(
                    fontSize: 12.5,
                    color: item.isRead
                        ? AppColors.textSecondary.withValues(alpha: emphasis)
                        : AppColors.textSecondary,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      color: AppColors.textLight,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.timeAgo(item.createdAt),
                      style: AppFonts.body(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
