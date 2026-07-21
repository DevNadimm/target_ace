import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/helpers/subscription_navigation_helper.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';

import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/auth/presentation/pages/profile_setup_page.dart';

class LoginPage extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const LoginPage());

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            final goal = await AppPreferences.getUserGoal();
            if (!context.mounted) return;

            if (goal.isEmpty) {
              Navigator.pushReplacement(context, ProfileSetupPage.route());
            } else {
              final status = state.authModel.subscription?.status ?? 'none';
              SubscriptionNavigationHelper.navigateByStatus(context, status);
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _LoginContent(state: state),
              if (state is AuthLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: const Loader(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  final AuthState state;

  const _LoginContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 84,
              right: 20,
              child: _FloatingPanel(
                size: 60,
                rotation: 0.22,
                color: AppColors.card,
              ),
            ),
            const Positioned(
              top: 150,
              right: 62,
              child: _FloatingPanel(
                size: 34,
                rotation: -0.18,
                color: AppColors.card,
                glow: true,
              ),
            ),
            const Positioned(
              top: 120,
              left: 12,
              child: _FloatingPanel(
                size: 70,
                rotation: -0.30,
                color: AppColors.card,
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppConfig.appName,
                      style: AppFonts.heading(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: _LiveRankPreviewCard(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beat the clock.\nOwn the rank.',
                        style: AppFonts.heading(
                          fontSize: 38,
                          height: 1.12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Sign in to join tonight's live battle",
                        style: AppFonts.body(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (state is AuthFailure && (state as AuthFailure).message != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            (state as AuthFailure).message!,
                            style: AppFonts.body(
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Builder(
                        builder: (ctx) {
                          return SizedBox(
                            width: double.infinity,
                            child: SpringButton(
                              backgroundColor: AppColors.white,
                              shadowColor: AppColors.textLight,
                              onPressed: () {
                                ctx.read<AuthBloc>().add(
                                  GoogleSignInRequested(),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(Assets.google, scale: 12),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Continue with Google',
                                    style: AppFonts.body(
                                      color: AppColors.textLight,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: AppFonts.body(
                            fontSize: 11.5,
                            color: AppColors.textLight,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveRankPreviewCard extends StatelessWidget {
  const _LiveRankPreviewCard();

  static const _rows = [
    (rank: 1, name: 'Rafiq Ahmed', score: 98),
    (rank: 2, name: 'Sadia Islam', score: 95),
    (rank: 3, name: 'Tanvir Hasan', score: 91),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.labelGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'LIVE · BCS 46th Battle',
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.labelGreen,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Text(
                '2,481 in',
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final row in _rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: row.rank == 1
                        ? const HugeIcon(
                            icon: HugeIcons.strokeRoundedCrown,
                            color: AppColors.accentYellow,
                            size: 16,
                          )
                        : Center(
                            child: Text(
                              '${row.rank}',
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                                height: 1,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.name,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${row.score}',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          CustomDivider.dotted(),
          const SizedBox(height: 10),
          Text(
            'Sign in to see where you\u2019d rank',
            style: AppFonts.body(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingPanel extends StatelessWidget {
  final double size;
  final double rotation;
  final Color color;
  final bool glow;

  const _FloatingPanel({
    required this.size,
    required this.rotation,
    required this.color,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
      ),
    );
  }
}
