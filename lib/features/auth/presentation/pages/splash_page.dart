import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/helpers/subscription_navigation_helper.dart';
import 'package:target_ace/features/auth/data/repos/auth_repo.dart';
import 'package:target_ace/features/auth/presentation/pages/login_page.dart';
import 'package:target_ace/features/auth/presentation/pages/onboarding_page.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';

import 'package:target_ace/features/auth/presentation/pages/profile_setup_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // First-time launch → show onboarding
    final isFirstTime = await AppPreferences.isFirstTime();
    if (!mounted) return;
    if (isFirstTime) {
      Navigator.pushReplacement(context, OnboardingPage.route());
      return;
    }

    // Returning user — check Supabase session
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context, LoginPage.route());
    } else {
      final goal = await AppPreferences.getUserGoal();
      final phone = await AppPreferences.getUserPhone();
      final gender = await AppPreferences.getUserGender();
      if (!mounted) return;

      if (goal.isEmpty || phone.isEmpty || gender.isEmpty) {
        // Sync/Refresh profile data from Supabase DB to check if they exist on server but not locally
        await AuthRepo.syncProfile();
        if (!mounted) return;

        final updatedGoal = await AppPreferences.getUserGoal();
        final updatedPhone = await AppPreferences.getUserPhone();
        final updatedGender = await AppPreferences.getUserGender();

        if (!mounted) return;
        if (updatedGoal.isEmpty || updatedPhone.isEmpty || updatedGender.isEmpty) {
          Navigator.pushReplacement(context, ProfileSetupPage.route());
          return;
        }
      }

      if (!mounted) return;
      context.read<SubscriptionBloc>().add(FetchSubscriptionStatus());

    }
  }




  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) async {
        if (state is SubscriptionLoaded || state is SubscriptionError) {
          final goal = await AppPreferences.getUserGoal();
          if (!context.mounted) return;

          if (goal.isEmpty) {
            Navigator.pushReplacement(context, ProfileSetupPage.route());
            return;
          }

          if (state is SubscriptionLoaded) {
            SubscriptionNavigationHelper.navigateByStatus(
              context,
              state.subscription.status,
            );
          } else {
            // Even on subscription fetch error, grant full access to dashboard
            SubscriptionNavigationHelper.navigateByStatus(context, 'active');
          }
        }
      },
      child: Scaffold(
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
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppConfig.appSubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 28),
                Loader(
                  isShowContainer: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
