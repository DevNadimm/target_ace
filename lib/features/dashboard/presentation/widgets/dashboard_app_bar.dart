import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';
import 'package:target_ace/core/components/premium_avatar_ring.dart';
import 'package:target_ace/core/utils/helpers/greeting_helper.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_page.dart';
import 'package:target_ace/features/notification/presentation/pages/notification_page.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int unreadNotificationsCount;
  final bool isPremium;

  const DashboardAppBar({
    super.key,
    this.unreadNotificationsCount = 0,
    this.isPremium = false,
  });

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  String _userName = 'User';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await UserLocalDataSource.getUserName();
    final avatarUrl = await UserLocalDataSource.getUserAvatarUrl();
    if (mounted) {
      setState(() {
        _userName = name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'User';
        _avatarUrl = avatarUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _avatarUrl.isNotEmpty
        ? CustomCachedImage(
            imageUrl: _avatarUrl,
            width: 40,
            height: 40,
            borderRadius: 20,
            backgroundColor: AppColors.card,
            errorIcon: HugeIcons.strokeRoundedUser03,
            errorIconColor: AppColors.grey,
            placeholderSize: PlaceholderSize.small,
          )
        : Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppColors.grey,
                size: 24,
              ),
            ),
          );

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, ProfilePage.route()),
              child: Row(
                children: [
                  PremiumAvatarRing(
                    size: 40,
                    isPremium: widget.isPremium,
                    borderWidth: 2.0,
                    padding: 2.0,
                    child: avatarWidget,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GreetingHelper.getGreeting(),
                          style: AppFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName,
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          CustomIconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  color: AppColors.textPrimary,
                ),
                if (widget.unreadNotificationsCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.background, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          widget.unreadNotificationsCount > 99
                              ? '99+'
                              : '${widget.unreadNotificationsCount}',
                          style: AppFonts.body(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Notifications',
            onTap: () async {
              await Navigator.push(context, NotificationPage.route());
              if (context.mounted) {
                context.read<DashboardBloc>().add(DashboardFetchRequested(isSilent: true));
              }
            },
          ),
        ],
      ),
    );
  }
}
