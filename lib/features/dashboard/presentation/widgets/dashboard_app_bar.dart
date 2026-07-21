import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/pages/under_development_page.dart';
import 'package:target_ace/core/utils/helpers/greeting_helper.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_page.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

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
    final name = await AppPreferences.getUserName();
    final avatarUrl = await AppPreferences.getUserAvatarUrl();
    if (mounted) {
      setState(() {
        _userName = name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'User';
        _avatarUrl = avatarUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _avatarUrl.isNotEmpty
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
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: AppColors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GreetingHelper.getGreeting(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          maxLines: 1,
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
            size: 48,
            backgroundColor: AppColors.card,
            icon: Stack(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  color: AppColors.textPrimary,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Notifications',
            onTap: () {
              Navigator.push(context, UnderDevelopmentPage.route());
            },
          ),
        ],
      ),
    );
  }
}

