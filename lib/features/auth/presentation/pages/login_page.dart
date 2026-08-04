import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/inline_error_widget.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:target_ace/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:target_ace/features/auth/presentation/widgets/live_rank_preview_card.dart';
import 'package:target_ace/features/auth/presentation/widgets/floating_panel.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';


class LoginPage extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const LoginPage());

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Notify the launch coordinator — it decides what comes next.
          context.read<AppLaunchBloc>().add(const LoginCompleted());
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
              child: FloatingPanel(
                size: 60,
                rotation: 0.22,
                color: AppColors.card,
              ),
            ),
            const Positioned(
              top: 150,
              right: 62,
              child: FloatingPanel(
                size: 34,
                rotation: -0.18,
                color: AppColors.card,
                glow: true,
              ),
            ),
            const Positioned(
              top: 120,
              left: 12,
              child: FloatingPanel(
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
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: LiveRankPreviewCard(),
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
                      if (state is AuthFailure && (state as AuthFailure).message != null) ...[
                        InlineErrorWidget((state as AuthFailure).message),
                        const SizedBox(height: 16),
                      ] else ...[
                        const SizedBox(height: 28),
                      ],
                      const GoogleSignInButton(),
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
