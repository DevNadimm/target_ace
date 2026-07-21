import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_hub_page.dart';
import 'package:target_ace/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:target_ace/features/dashboard/presentation/pages/leaderboard_page.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const MainNavigationPage());

  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => MainNavigationPageState();
}

class MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  String _avatarUrl = '';

  void setIndex(int index) {
    if (_currentIndex != index) {
      _buildPage(index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// Lazily built pages — only initialized when the user first visits the tab.
  /// This prevents all 4 tabs from firing their initState() and API calls on startup.
  final Map<int, Widget> _builtPages = {};

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final url = await AppPreferences.getUserAvatarUrl();
    if (mounted) {
      setState(() {
        _avatarUrl = url;
      });
    }
  }

  Widget _buildPage(int index) {
    return _builtPages.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return const DashboardPage();
        case 1:
          return const LiveBattleHubPage();
        case 2:
          return const LeaderboardPage();
        case 3:
          return const ProfilePage();
        default:
          return const DashboardPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(4, (index) {
          if (_builtPages.containsKey(index)) {
            return _builtPages[index]!;
          }
          if (index == _currentIndex) {
            return _buildPage(index);
          }
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  strokeIcon: Assets.homeOutlined,
                  solidIcon: Assets.homeFilled,
                ),
                _buildNavItem(
                  index: 1,
                  strokeIcon: Assets.boltOutlined,
                  solidIcon: Assets.boltFilled,
                ),
                _buildNavItem(
                  index: 2,
                  strokeIcon: Assets.awardOutlined,
                  solidIcon: Assets.awardFilled,
                ),
                _buildNavItem(
                  index: 3,
                  strokeIcon: Assets.profileOutlined,
                  solidIcon: Assets.profileFilled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String strokeIcon,
    required String solidIcon,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textLight;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          _buildPage(index);
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: index == 3
            ? Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textLight.withValues(alpha: 0.4),
                    width: isSelected ? 2.2 : 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _avatarUrl.isNotEmpty
                        ? CustomCachedImage(
                            imageUrl: _avatarUrl,
                            width: 24,
                            height: 24,
                            borderRadius: 12,
                          )
                        : SvgPicture.asset(
                            isSelected ? solidIcon : strokeIcon,
                            colorFilter: ColorFilter.mode(
                              color,
                              BlendMode.srcIn,
                            ),
                            width: 18,
                            height: 18,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              )
            : SvgPicture.asset(
                isSelected ? solidIcon : strokeIcon,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
