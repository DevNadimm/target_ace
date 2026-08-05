import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';

class OnboardingPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const OnboardingPage());

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await AppPreferences.setFirstTime(false);
    if (!mounted) return;
    context.read<AppLaunchBloc>().add(const OnboardingCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<_OnboardingItem> items = [
      _OnboardingItem(
        title: 'Compete in Live Battle Exams',
        subtitle: 'Join thousands of students in real-time MCQ battles. Only the best rise to the top.',
        icon: HugeIcons.strokeRoundedFire02,
        color: AppColors.primary,
      ),
      _OnboardingItem(
        title: 'Your Target, Your Leaderboard',
        subtitle: 'Pick your goal — BCS, Admission, HSC — and compete only with students on the same path.',
        icon: HugeIcons.strokeRoundedCrown,
        color: AppColors.success,
      ),
      _OnboardingItem(
        title: 'Prepare Smarter. Rank Higher.',
        subtitle: 'Practice with past exams, track your rank history, and level up your preparation every day.',
        icon: HugeIcons.strokeRoundedChart,
        color: AppColors.warning,
      ),
    ];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _currentPage == 2 ? null : _onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    _currentPage == 2 ? '' : 'Skip',
                    style: AppFonts.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPageWidget(
                      item: items[index],
                      isVisible: _currentPage == index,
                      size: size,
                    );
                  },
                ),
              ),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(
                        items.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next/Start Button
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == 2 ? 'Get Started' : 'Next',
                            style: AppFonts.style(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentPage < 2) ...[
                            const SizedBox(width: 8),
                            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;
  final Color color;

  _OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingItem item;
  final bool isVisible;
  final Size size;

  const _OnboardingPageWidget({
    required this.item,
    required this.isVisible,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isVisible ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  height: size.width * 0.6,
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: size.width * 0.4,
                        width: size.width * 0.4,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      HugeIcon(
                        icon: item.icon,
                        color: item.color,
                        size: size.width * 0.2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 60),

          // Animated Text
          AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(top: isVisible ? 0 : 20),
              child: Column(
                children: [
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: AppFonts.style(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
