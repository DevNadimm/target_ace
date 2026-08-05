import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/auth/presentation/pages/login_page.dart';
import 'package:target_ace/features/auth/presentation/pages/onboarding_page.dart';
import 'package:target_ace/features/home/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/notification/presentation/pages/notification_permission_page.dart';
import 'package:target_ace/features/profile/presentation/bloc/setup/profile_setup_cubit.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:target_ace/features/subscription/presentation/pages/free_trial_offer_page.dart';

/// Root launch page â€” the single entry point for the entire app.
///
/// Replaces the old `SplashPage`. Hosts a [BlocListener] that reacts to
/// [AppLaunchState] emissions and renders the appropriate screen.
///
/// During [AppLaunchInitializing], the splash UI (logo + loader) is shown.
/// All subsequent states swap the child widget via [AnimatedSwitcher].
/// The terminal [AppLaunchNavigateHome] triggers `Navigator.pushAndRemoveUntil`
/// to enter the main app, clearing the launch stack.
class LaunchPage extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const LaunchPage());

  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLaunchBloc, AppLaunchState>(
      listener: (context, state) {
        switch (state) {
          case AppLaunchNavigateHome():
            Navigator.pushAndRemoveUntil(
              context,
              MainNavigationPage.route(),
              (_) => false,
            );
          default:
            // Other states are handled by the builder below.
            break;
        }
      },
      child: BlocBuilder<AppLaunchBloc, AppLaunchState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _buildScreen(context, state),
          );
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, AppLaunchState state) {
    return switch (state) {
      AppLaunchInitializing() => const _SplashView(key: ValueKey('splash')),
      AppLaunchShowOnboarding() =>
        const OnboardingPage(key: ValueKey('onboarding')),
      AppLaunchShowLogin() => const LoginPage(key: ValueKey('login')),
      AppLaunchShowProfileSetup() => BlocProvider(
          create: (_) => sl<ProfileSetupCubit>(),
          child: const ProfileSetupPage(key: ValueKey('profile_setup')),
        ),
      AppLaunchShowNotificationPermission() =>
        const NotificationPermissionPage(key: ValueKey('notification')),
      AppLaunchShowFreeTrial() =>
        const FreeTrialOfferPage(key: ValueKey('free_trial')),
      // Terminal states are handled by the listener, but render splash
      // as a fallback to prevent frame-level blank screens.
      AppLaunchNavigateHome() => const _SplashView(key: ValueKey('splash')),
      AppLaunchError() => const LoginPage(key: ValueKey('login_error')),
    };
  }
}

/// Splash screen UI â€” shown during [AppLaunchInitializing].
///
/// Preserves the exact same visual design from the old `SplashPage`:
/// centered logo, app name, subtitle, and a loading indicator.
class _SplashView extends StatelessWidget {
  const _SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    bottom: BorderSide(
                      width: 4,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  image: DecorationImage(image: AssetImage(Assets.appLogo)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConfig.appName,
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppConfig.appSubtitle,
                style: AppFonts.body(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 28),
              const Loader(
                isShowContainer: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}