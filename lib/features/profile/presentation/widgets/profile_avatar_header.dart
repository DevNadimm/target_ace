import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/components/premium_avatar_ring.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class ProfileAvatarHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarUrl;

  final bool isPremium;

  const ProfileAvatarHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = avatarUrl.isNotEmpty
        ? CustomCachedImage(
            imageUrl: avatarUrl,
            width: 60,
            height: 60,
            borderRadius: 30,
          )
        : Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: AppFonts.body(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          );

    return Row(
      children: [
        PremiumAvatarRing(
          size: 60,
          isPremium: isPremium,
          child: avatarWidget,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (userEmail.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}