import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final String avatarUrl;
  final bool isMe;
  final double avatarSize;
  final Widget? subtitle;
  final Widget? trailing;
  final double rankWidth;
  final bool hasBottomBorder;
  final EdgeInsetsGeometry padding;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.isMe,
    this.avatarSize = 36.0,
    this.subtitle,
    this.trailing,
    this.rankWidth = 32.0,
    this.hasBottomBorder = false,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    Widget rowContent = Row(
      children: [
        // Rank Indicator
        SizedBox(
          width: rankWidth,
          child: Text(
            '#$rank',
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
              color: isMe ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
        _buildAvatar(avatarUrl, name, avatarSize, isMe),
        const SizedBox(width: 12),

        // User Info (Name & Custom Subtitle)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: AppFonts.body(
                        fontSize: 14.5,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                        color: isMe ? AppColors.primary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "YOU",
                        style: AppFonts.body(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                subtitle!,
              ],
            ],
          ),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing!,
      ],
    );

    if (hasBottomBorder) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
        ),
        child: rowContent,
      );
    }

    return Container(
      padding: padding,
      child: rowContent,
    );
  }

  Widget _buildAvatar(String avatarUrl, String name, double size, bool isMe) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isMe ? AppColors.primary : AppColors.divider.withValues(alpha: 0.5),
          width: isMe ? 2.0 : 1.2,
        ),
      ),
      child: avatarUrl.isNotEmpty
          ? CustomCachedImage(
              imageUrl: avatarUrl,
              width: size,
              height: size,
              borderRadius: size / 2,
            )
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: (isMe ? AppColors.primary : AppColors.grey).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: AppFonts.body(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.bold,
                    color: isMe ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
    );
  }
}
