import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/subscription_navigation_helper.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';

class SubscriptionPendingPage extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const SubscriptionPendingPage());

  const SubscriptionPendingPage({super.key});

  void _checkStatus(BuildContext context) {
    context.read<SubscriptionBloc>().add(
      FetchSubscriptionStatus(isManualCheck: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionLoaded) {
          if (state.subscription.status == 'pending_verification') {
            if (state.isManualCheck) {
              AppNotifier.showSnackBar(context, 'Your subscription is still under review. Please wait.', type: MessageType.error);
            }
          } else {
            SubscriptionNavigationHelper.navigateByStatus(
              context,
              state.subscription.status,
            );
          }
        } else if (state is SubscriptionError) {
          AppNotifier.showSnackBar(context, state.message ?? 'Something Went Wrong!', type: MessageType.error);
        }
      },
      builder: (context, state) {
        final isChecking = state is SubscriptionLoading;

        return Scaffold(
          appBar: DashboardAppBar(),
          body: GradientBackground(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PendingLedger(),
                    const SizedBox(height: 36),
                    Text(
                      'Subscription Pending',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "We've received your payment request. Our team is verifying it â€” this usually takes a few hours.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SpringButton(
                      onPressed: isChecking
                          ? () {}
                          : () => _checkStatus(context),
                      child: isChecking
                          ? Loader(color: Colors.white, isShowContainer: false)
                          : const Text('Check Status'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        final userName = await AppPreferences.getUserName();
                        final userId = await AppPreferences.getUserId();
                        final plan = await AppPreferences.getSubscriptionPlanName();

                        final message = '''
à¦†à¦¸à¦¸à¦¾à¦²à¦¾à¦®à§ à¦†à¦²à¦¾à¦‡à¦•à§à¦®,

à¦†à¦®à¦¿ ${AppConfig.appName} à¦…à§à¦¯à¦¾à¦ªà§‡ à¦ªà§‡à¦®à§‡à¦¨à§à¦Ÿ à¦•à¦°à§‡à¦›à¦¿, à¦•à¦¿à¦¨à§à¦¤à§ à¦à¦–à¦¨à§‹ à¦­à§‡à¦°à¦¿à¦«à¦¿à¦•à§‡à¦¶à¦¨ à¦ªà§‡à¦¨à§à¦¡à¦¿à¦‚ à¦†à¦›à§‡à¥¤ à¦à¦‡ à¦¬à¦¿à¦·à¦¯à¦¼à§‡ à¦¸à¦¹à¦¾à¦¯à¦¼à¦¤à¦¾ à¦ªà§à¦°à¦¯à¦¼à§‹à¦œà¦¨à¥¤

- Name: $userName
- User ID: $userId
- Plan: $plan
- App Version: ${AppConfig.appVersion}

à¦§à¦¨à§à¦¯à¦¬à¦¾à¦¦à¥¤
''';

                        final uri = Uri.parse(AppConfig.supportWhatsAppUrl(message));
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          debugPrint('Error launching support URL: $e');
                        }
                      },
                      child: Text(
                        'Need Help?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PendingLedger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 16,
            bottom: 16,
            left: 46,
            right: 12,
            child: _flatCard(AppColors.surface.withValues(alpha: 0.9)),
          ),
          Positioned(
            top: 19,
            bottom: 19,
            left: 43,
            right: 15,
            child: _flatCard(AppColors.surface),
          ),
          // Spine shadow strip
          Positioned(
            top: 22,
            bottom: 22,
            left: 38,
            width: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
            ),
          ),
          Positioned(
            top: 22,
            bottom: 22,
            left: 44,
            right: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryLight, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 22,
            bottom: 22,
            left: 44,
            right: 20,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 1.4,
                    color: AppColors.accentYellow.withValues(alpha: 0.75),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rent\nBook',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: AppColors.accentYellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 34,
                    height: 1.4,
                    color: AppColors.accentYellow.withValues(alpha: 0.75),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Transform.rotate(angle: -0.28, child: _PendingStamp()),
          ),
        ],
      ),
    );
  }

  Widget _flatCard(Color color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grey),
      ),
    );
  }
}

class _PendingStamp extends StatelessWidget {
  const _PendingStamp();

  static final Color _stampColor = Colors.orange.shade700;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: _stampColor),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Under\nReview',
                textAlign: TextAlign.center,
                style: GoogleFonts.stardosStencil(
                  fontSize: 9.5,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: _stampColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;

    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashCount = 36;
    const gapFraction = 0.45;
    for (var i = 0; i < dashCount; i++) {
      final startAngle = (2 * 3.14159265 / dashCount) * i;
      final sweep = (2 * 3.14159265 / dashCount) * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        outerPaint,
      );
    }

    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 8, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => false;
}

