import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/info_row.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/inline_error_widget.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/features/auth/presentation/pages/login_page.dart';
import 'package:target_ace/core/utils/helpers/subscription_navigation_helper.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:target_ace/features/subscription/utils/subscription_url_builder.dart';

class SubscriptionActivationPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const SubscriptionActivationPage());

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
    final token = await AppPreferences.getAccessToken();
    final url = buildSubscriptionUrl(
      token: token,
      sharedSecret: AppConfig.subscriptionSharedSecret,
      baseUrl: AppConfig.subscriptionPlanUrl,
    );
    final uri = Uri.parse(url);
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
          SubscriptionNavigationHelper.navigateByStatus(context, state.subscription.status);
        }
      },
      builder: (context, state) {
        final isChecking = state is SubscriptionLoading;
        String? inlineError;

        if (state is SubscriptionError) {
          inlineError = state.message;
        } else if (state is SubscriptionLoaded && state.subscription.status != 'active' && state.subscription.status != 'trial' && state.subscription.status != 'pending_verification' && state.subscription.status != 'expired' && state.subscription.status != 'cancelled') {
          if (state.isManualCheck) {
            inlineError = 'No active subscription found. Please visit the website to subscribe.';
          }
        }

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: canPop ? const BackButton() : null,
                actions: [
                  IconButton(
                    onPressed: () {
                      AppConfirmationDialog.show(
                        context,
                        title: 'Log Out',
                        message: 'Are you sure you want to log out?',
                        confirmText: 'Log Out',
                        isDestructive: true,
                        onConfirm: () async {
                          await AppPreferences.clearAll();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            LoginPage.route(), (_) => false,
                          );
                        },
                      );
                    },
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedLogout01,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: GradientBackground(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activate Your Account',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'To get started with Vara Khata, please visit our website to choose a plan and complete your subscription.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Subscription Information',
                        style: GoogleFonts.poppins(
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
                            const CustomDivider.dotted(),
                            InfoRow(
                              icon: HugeIcons.strokeRoundedStarAward02,
                              label: '7-day money-back guarantee',
                              value: 'No questions asked if you change your mind',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Support & Legal',
                        style: GoogleFonts.poppins(
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
                                final userName = await AppPreferences.getUserName();
                                final userId = await AppPreferences.getUserId();
                                final plan = await AppPreferences.getSubscriptionPlanName();

                                final message = '''
à¦†à¦¸à¦¸à¦¾à¦²à¦¾à¦®à§ à¦†à¦²à¦¾à¦‡à¦•à§à¦®,

à¦†à¦®à¦¿ ${AppConfig.appName} à¦…à§à¦¯à¦¾à¦ª à¦¬à§à¦¯à¦¬à¦¹à¦¾à¦° à¦•à¦°à¦›à¦¿à¥¤ à¦†à¦®à¦¾à¦° à¦à¦•à¦Ÿà¦¿ à¦¬à¦¿à¦·à¦¯à¦¼à§‡ à¦¸à¦¹à¦¾à¦¯à¦¼à¦¤à¦¾ à¦ªà§à¦°à¦¯à¦¼à§‹à¦œà¦¨à¥¤

â€¢ à¦¨à¦¾à¦®: $userName
â€¢ User ID: $userId
â€¢ à¦ªà§à¦²à§à¦¯à¦¾à¦¨: ${plan.isNotEmpty ? plan : 'No Active Plan'}
â€¢ App Version: ${AppConfig.appVersion}

à¦†à¦®à¦¾à¦° à¦¸à¦®à¦¸à§à¦¯à¦¾à¦Ÿà¦¿:
(à¦…à¦¨à§à¦—à§à¦°à¦¹ à¦•à¦°à§‡ à¦à¦–à¦¾à¦¨à§‡ à¦²à¦¿à¦–à§à¦¨)

à¦§à¦¨à§à¦¯à¦¬à¦¾à¦¦à¥¤
''';

                                _launchURL(AppConfig.supportWhatsAppUrl(message));
                              },                          ),
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
                      const SizedBox(height: 28),
                      SpringButton(
                        width: double.infinity,
                        onPressed: _openWebsite,
                        child: Text('Visit Website to Subscribe'),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _checkActivationStatus,
                          child: Text(
                            'Already Subscribed? Check Status',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ),
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

