import 'package:flutter/material.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/config/typography.dart';

class PodiumWidgetUser {
  final String name;
  final String avatarUrl;
  final double score;
  final bool isMe;

  PodiumWidgetUser({
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.isMe,
  });
}

class PodiumWidget extends StatelessWidget {
  final List<PodiumWidgetUser?> users; // Exactly length 3: [1st, 2nd, 3rd]
  final String scoreSuffix; // e.g. 'pts' or '/100'

  const PodiumWidget({
    super.key,
    required this.users,
    required this.scoreSuffix,
  }) : assert(users.length == 3);

  @override
  Widget build(BuildContext context) {
    final user1 = users[0];
    final user2 = users[1];
    final user3 = users[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Rank 2 (Left) ──
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user2 != null) ...[
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatar(user2.avatarUrl, user2.name, 60, user2.isMe),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          Assets.secondBadge,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user2.name.split(' ').first,
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user2.score.round()}$scoreSuffix',
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 118),
              const SizedBox(height: 16),
              _build3DPodiumWidgetBlock("2nd", 80, AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ── Rank 1 (Center) ──
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user1 != null) ...[
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatar(user1.avatarUrl, user1.name, 76, user1.isMe),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          Assets.firstBadge,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user1.name.split(' ').first,
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.labelGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user1.score.round()}$scoreSuffix',
                    style: AppFonts.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.labelGreen,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 134),
              const SizedBox(height: 16),
              _build3DPodiumWidgetBlock("1st", 110, AppColors.primary),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // ── Rank 3 (Right) ──
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user3 != null) ...[
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatar(user3.avatarUrl, user3.name, 60, user3.isMe),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          Assets.thirdBadge,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user3.name.split(' ').first,
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user3.score.round()}$scoreSuffix',
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 118),
              const SizedBox(height: 16),
              _build3DPodiumWidgetBlock("3rd", 60, const Color(0xFFCD7F32)),
            ],
          ),
        ),
      ],
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
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: isMe ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _build3DPodiumWidgetBlock(String rank, double height, Color accentColor) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.cardAlt,
          borderRadius: BorderRadius.circular(11),
          border: Border.fromBorderSide(
            BorderSide(
              color: accentColor.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            rank,
            style: AppFonts.heading(
              fontSize: rank == "1st" ? 34 : (rank == "2nd" ? 28 : 22),
              fontWeight: rank == "1st" ? FontWeight.w900 : (rank == "2nd" ? FontWeight.w800 : FontWeight.w700),
              color: accentColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
