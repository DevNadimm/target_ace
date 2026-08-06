import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_arena_page.dart';
import 'package:target_ace/features/home/presentation/pages/home_page.dart';
import 'package:target_ace/features/home/presentation/pages/leaderboard_page.dart';
import 'package:target_ace/features/practice/presentation/pages/practice_dashboard_page.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_page.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/features/home/presentation/bloc/home_bloc.dart';
import 'package:target_ace/features/battle/presentation/bloc/arena/battle_arena_bloc.dart';
class MainNavigationPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<HomeBloc>()),
            BlocProvider(create: (_) => sl<BattleArenaBloc>()),
          ],
          child: const MainNavigationPage(),
        ),
      );

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

  /// Lazily built pages â€” only initialized when the user first visits the tab.
  final Map<int, Widget> _builtPages = {};

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final url = await UserLocalDataSource.getUserAvatarUrl();
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
          return const HomePage();
        case 1:
          return const BattleArenaPage();
        case 2:
          return const PracticeDashboardPage();
        case 3:
          return const LeaderboardPage();
        case 4:
          return const ProfilePage();
        default:
          return const HomePage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        AppConfirmationDialog.show(
          context,
          title: 'Exit App',
          message: 'Are you sure you want to exit TargetAce?',
          confirmText: 'Exit',
          cancelText: 'Cancel',
          isDestructive: true,
          onConfirm: () {
            SystemNavigator.pop();
          },
        );
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(5, (index) {
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
                    strokeIcon: Assets.bookOutlined,
                    solidIcon: Assets.bookFilled,
                  ),
                  _buildNavItem(
                    index: 3,
                    strokeIcon: Assets.awardOutlined,
                    solidIcon: Assets.awardFilled,
                  ),
                  _buildNavItem(
                    index: 4,
                    strokeIcon: Assets.profileOutlined,
                    solidIcon: Assets.profileFilled,
                  ),
                ],
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: index == 4
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