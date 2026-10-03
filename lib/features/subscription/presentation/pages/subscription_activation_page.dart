import 'dart:math' as math;
import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/info_row.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/inline_error_widget.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/home/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/core/services/service_locator.dart';

class SubscriptionActivationPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<SubscriptionBloc>(),
      child: const SubscriptionActivationPage(),
    ),
  );

  const SubscriptionActivationPage({super.key});

  @override
  State<SubscriptionActivationPage> createState() => _SubscriptionActivationPageState();
}

class _SubscriptionActivationPageState extends State<SubscriptionActivationPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkActivationStatus();
    }
  }

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Could not open link: $urlString', type: MessageType.error);
      }
    }
  }

  void _checkActivationStatus() {
    context.read<SubscriptionBloc>().add(FetchSubscriptionStatus(isManualCheck: true));
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionLoaded) {
          final status = state.subscription.status;
          if (status == 'active' || status == 'trial') {
            Navigator.pushAndRemoveUntil(
              context,
              MainNavigationPage.route(), (_) => false,
            );
          }
        }
      },
      builder: (context, state) {
        final isChecking = state is SubscriptionLoading;
        String? inlineError;

        if (state is SubscriptionError) {
          inlineError = state.message;
        } else if (state is SubscriptionLoaded) {
          final status = state.subscription.status;
          if (status != 'active' && status != 'trial' && status != 'pending_verification' && status != 'pending') {
            if (status == 'expired') {
              inlineError = 'Your membership is currently inactive. Tap below to refresh your status or contact support for assistance.';
            } else {
              inlineError = 'No active membership found. Please check back shortly or contact support if you need assistance.';
            }
          }
        }

        String headerTitle = 'Premium Membership';
        String headerSubtext = 'Unlock exclusive features and content with an active TargetAce membership. Check your account status below.';
        bool isPendingStatus = false;

        if (state is SubscriptionLoaded) {
          final status = state.subscription.status;
          if (status == 'expired') {
            headerTitle = 'Membership Inactive';
            headerSubtext = 'Your membership is currently inactive. Refresh your account status to check for updates, or reach out to support for help.';
          } else if (status == 'pending_verification' || status == 'pending') {
            headerTitle = 'Account Under Review';
            headerSubtext = 'Your account details are currently being verified. Verification usually completes within 2 to 24 hours. Your access will unlock automatically once confirmed.';
            isPendingStatus = true;
          } else if (status == 'cancelled') {
            headerTitle = 'Membership Cancelled';
            headerSubtext = 'Your membership was cancelled. Contact support or check your account status for any updates.';
          }
        }

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: canPop ? const BackButton() : null,
              ),
              body: GradientBackground(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -20 * math.pi / 180,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDiamond02,
                              color: AppColors.info,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        headerTitle,
                        style: AppFonts.heading(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        headerSubtext,
                        style: AppFonts.body(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'How to Activate',
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomContainer(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            InfoRow(
                              icon: HugeIcons.strokeRoundedGlobe02,
                              label: 'Visit ${Uri.parse(AppConfig.websiteUrl).host}',
                              value: 'Open our website on your browser',
                              onTap: () => _launchURL(AppConfig.websiteUrl),
                            ),
                            const CustomDivider.dotted(),
                            InfoRow(
                              icon: HugeIcons.strokeRoundedCheckmarkSquare02,
                              label: 'Choose your plan',
                              value: 'Select a preparation plan and complete activation',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Support',
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomContainer(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            InfoRow(
                              icon: HugeIcons.strokeRoundedWhatsapp,
                              label: 'Contact Support',
                              value: 'Chat with us on WhatsApp',
                              onTap: () async {
                                final userName = await UserLocalDataSource.getUserName();
                                final userId = await UserLocalDataSource.getUserId();
                                final plan = await UserLocalDataSource.getSubscriptionPlanName();

                                final message = '''
Assalamu Alaikum,

I am using ${AppConfig.appName} app. I need help regarding my subscription / account.

● Name: $userName
● User ID: $userId
● Plan: ${plan.isNotEmpty ? plan : 'No Active Plan'}
● App Version: ${AppConfig.appVersion}

My issue:
(Please write here)

Thank you.
''';

                                _launchURL(AppConfig.supportWhatsAppUrl(message));
                              },
                            ),
                          ],
                        ),
                      ),
                      InlineErrorWidget(inlineError),
                      const SizedBox(height: 32),
                      SpringButton(
                        width: double.infinity,
                        onPressed: _checkActivationStatus,
                        child: Text('CHECK ACTIVATION STATUS'),
                      ),
                      if (!isPendingStatus) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            'Status updates automatically when you return to the app.',
                            textAlign: TextAlign.center,
                            style: AppFonts.body(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            if (isChecking)
              Container(
                color: AppColors.black.withValues(alpha: 0.6),
                child: const Center(child: Loader()),
              ),
          ],
        );
      },
    );
  }
}
