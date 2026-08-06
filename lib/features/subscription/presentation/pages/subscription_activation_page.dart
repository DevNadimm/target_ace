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

  Future<void> _openWebsite() async {
    final uri = Uri.parse(AppConfig.subscriptionPlanUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch subscription URL: $e');
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
              inlineError = 'Your subscription has expired. Please renew your plan.';
            } else {
              inlineError = 'No active subscription found. Please subscribe to gain full access.';
            }
          }
        }

        String headerTitle = 'Premium Access';
        String headerSubtext = 'Visit our website to choose a plan, claim your 7-day Free Trial, or complete your subscription.';
        String mainButtonText = 'Visit Website to Subscribe';
        VoidCallback mainButtonAction = _openWebsite;
        bool isPendingStatus = false;

        if (state is SubscriptionLoaded) {
          final status = state.subscription.status;
          if (status == 'expired') {
            headerTitle = 'Renew Your Subscription';
            headerSubtext = 'Your subscription has ended. Renew now on our website to continue live battles and full analytics.';
            mainButtonText = 'Renew Subscription on Website';
            mainButtonAction = _openWebsite;
          } else if (status == 'pending_verification' || status == 'pending') {
            headerTitle = 'Payment Under Review';
            headerSubtext = 'Your payment details are currently being verified by admin. Verification usually completes within 2 to 24 hours.';
            mainButtonText = 'Check Verification Status';
            mainButtonAction = _checkActivationStatus;
            isPendingStatus = true;
          } else if (status == 'cancelled') {
            headerTitle = 'Reactivate Plan';
            headerSubtext = 'Your subscription was cancelled. Visit our website anytime to reactivate your plan.';
            mainButtonText = 'Reactivate Plan on Website';
            mainButtonAction = _openWebsite;
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
                        'Subscription Information',
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
                              icon: HugeIcons.strokeRoundedSmartPhone01,
                              label: 'bKash & Nagad accepted',
                              value: 'Pay easily with local mobile banking',
                            ),
                            const CustomDivider.dotted(),
                            InfoRow(
                              icon: HugeIcons.strokeRoundedClock01,
                              label: 'Activated within 24 hours',
                              value: 'Your account goes live after payment review',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Support & Legal',
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

• Name: $userName
• User ID: $userId
• Plan: ${plan.isNotEmpty ? plan : 'No Active Plan'}
• App Version: ${AppConfig.appVersion}

My issue:
(Please write here)

Thank you.
''';

                                _launchURL(AppConfig.supportWhatsAppUrl(message));
                              },
                            ),
                            const CustomDivider.dotted(),
                            InfoRow(
                              icon: HugeIcons.strokeRoundedLegalDocument01,
                              label: 'Terms & Conditions',
                              value: 'Read our terms of service',
                              onTap: () => _launchURL(AppConfig.termsUrl),
                            ),
                            const CustomDivider.dotted(),
                            InfoRow(
                              icon: HugeIcons.strokeRoundedShield02,
                              label: 'Privacy Policy',
                              value: 'Read our privacy policy',
                              onTap: () => _launchURL(AppConfig.privacyUrl),
                            ),
                          ],
                        ),
                      ),
                      InlineErrorWidget(inlineError),
                      const SizedBox(height: 32),
                      SpringButton(
                        width: double.infinity,
                        onPressed: mainButtonAction,
                        child: Text(mainButtonText),
                      ),
                      if (!isPendingStatus) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: _checkActivationStatus,
                            child: Text(
                              'Already Subscribed? Check Status',
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
                              ),
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