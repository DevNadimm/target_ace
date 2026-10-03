import 'package:target_ace/core/config/messages.dart';
import 'package:flutter/material.dart' hide BackButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:target_ace/features/profile/domain/enums/profile_step_type.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/info_row.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/components/stat_card.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:target_ace/features/profile/presentation/bloc/profile/profile_cubit.dart';
import 'package:target_ace/features/profile/presentation/widgets/inactive_subscription_card.dart';
import 'package:target_ace/features/profile/presentation/widgets/profile_avatar_header.dart';
import 'package:target_ace/main.dart';

class ProfilePage extends StatelessWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const ProfilePage());

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const ProfilePageView(),
    );
  }
}

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        leading: ModalRoute.of(context)?.canPop == true ? const BackButton() : null,
      ),
      body: GradientBackground(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            debugPrint("ProfilePageView AuthBloc state changed: $state");
            if (state is AuthFailure) {
              debugPrint("Logout failed: ${state.message}");
              AppNotifier.showSnackBar(context, state.message ?? 'An error occurred', type: MessageType.error);
            }
          },
          child: BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (prev, curr) {
              // Skip rebuild if data hasn't actually changed
              if (prev is ProfileLoaded && curr is ProfileLoaded) {
                return prev.profileData != curr.profileData;
              }
              return true;
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: Loader());
              }

              if (state is ProfileFailure) {
                return Center(
                  child: Text(
                    state.error ?? AppMessages.errorMessage,
                    style: AppFonts.body(color: AppColors.error),
                  ),
                );
              }

              final data = (state as ProfileLoaded).profileData;
              final String userName = data.name;
              final String userEmail = data.email;
              final String userPhone = data.phone;
              final String userGender = data.gender;
              final String userDob = data.dob;
              final String userInstitution = data.institution;
              final String userDistrict = data.district;
              final String avatarUrl = data.avatarUrl;
              final String planName = data.subscriptionPlanName;
              final String subStatus = data.subscriptionStatus;
              final String subExpiry = data.subscriptionExpiry;
              final String activeGroup = data.activeGroupTitle;

              final displayPlanName = planName.isNotEmpty ? planName : (subStatus == 'active' ? 'Premium Plan' : 'Free Member');

              String statusLabel() {
                final expiryDate = DateTime.tryParse(subExpiry);
                if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
                  return 'Expired';
                }
                switch (subStatus) {
                  case 'active':
                    return 'Active';
                  case 'expired':
                    return 'Expired';
                  case 'cancelled':
                    return 'Cancelled';
                  case 'pending_verification':
                  case 'pending':
                    return 'Pending';
                  case 'trial':
                    return 'Active';
                  default:
                    return 'Inactive';
                }
              }

              final isPremium = subStatus == 'active' || subStatus == 'trial';

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: SingleChildScrollView(
                  key: ValueKey(data.hashCode),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatarHeader(
                      userName: userName,
                      userEmail: userEmail,
                      avatarUrl: avatarUrl,
                      isPremium: isPremium,
                    ),
                    const SizedBox(height: 16),
                    if (isPremium)
                      Row(
                        children: [
                          StatCard(
                            label: 'Plan',
                            value: displayPlanName,
                            icon: HugeIcons.strokeRoundedDiamond02,
                            color: AppColors.primary,
                            isRaw: true,
                          ),
                          const SizedBox(width: 10),
                          StatCard(
                            label: 'Status',
                            value: statusLabel(),
                            icon: (subStatus == 'active' || subStatus == 'trial')
                                ? HugeIcons.strokeRoundedCheckmarkSquare02
                                : HugeIcons.strokeRoundedAlertSquare,
                            color: (subStatus == 'active' || subStatus == 'trial') ? AppColors.success : AppColors.error,
                            isRaw: true,
                          ),
                        ],
                      )
                    else
                      InactiveSubscriptionCard(status: subStatus),
                    const SizedBox(height: 24),
                    Text(
                      'My Information',
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
                            icon: HugeIcons.strokeRoundedCall02,
                            label: 'Phone',
                            value: userPhone.isNotEmpty ? userPhone : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedMail01,
                            label: 'Email',
                            value: userEmail.isNotEmpty ? userEmail : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedUser03,
                            label: 'Gender',
                            value: userGender.isNotEmpty ? userGender : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedCalendar04,
                            label: 'Date of Birth',
                            value: userDob.isNotEmpty ? DateFormatter.readable(userDob) : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedUniversity,
                            label: 'Institution',
                            value: userInstitution.isNotEmpty ? userInstitution : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedLocation01,
                            label: 'District',
                            value: userDistrict.isNotEmpty ? userDistrict : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedTarget01,
                            label: 'Battle Group',
                            value: activeGroup,
                            onTap: () async {
                              final didSwitch = await Navigator.push(
                                context,
                                ProfileSetupPage.route(
                                  customSteps: [
                                    ProfileStepType.goal,
                                    ProfileStepType.group,
                                  ],
                                ),
                              );
                              if (didSwitch == true && context.mounted) {
                                context.read<ProfileCubit>().loadProfile();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Subscription',
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
                            icon: HugeIcons.strokeRoundedDiamond02,
                            label: 'Current Plan',
                            value: displayPlanName,
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedCheckmarkSquare02,
                            label: 'Status',
                            value: statusLabel(),
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedCalendar04,
                            label: 'Expires On',
                            value: subExpiry.isNotEmpty ? DateFormatter.readable(subExpiry) : 'N/A',
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
                            value: 'Chat on WhatsApp',
                            onTap: () {
                              final message = '''
Assalamu Alaikum,

I am using ${AppConfig.appName} app. I need help with something.

● Name: $userName
● Plan: $planName
● App Version: ${AppConfig.appVersion}

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
                            value: 'Read',
                            onTap: () => _launchURL(AppConfig.termsUrl),
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedShield02,
                            label: 'Privacy Policy',
                            value: 'Read',
                            onTap: () => _launchURL(AppConfig.privacyUrl),
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedDelete02,
                            label: 'Delete Account',
                            value: 'Delete',
                            onTap: () => _onDeleteAccount(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SpringButton(
                      onPressed: () => _onLogout(context),
                      backgroundColor: AppColors.error,
                      shadowColor: AppColors.error.withAlpha(120),
                      child: const Text('Log Out', style: TextStyle(color: AppColors.white)),
                    ),
                  ],
                ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _onLogout(BuildContext context) {
    debugPrint("Show Logout Confirmation Dialog");
    AppConfirmationDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      isDestructive: true,
      onConfirm: () {
        debugPrint("Logout confirmed. Dispatching LogoutRequested to AuthBloc.");
        final globalContext = navigatorKey.currentContext;
        if (globalContext != null) {
          globalContext.read<AuthBloc>().add(LogoutRequested());
        } else {
          context.read<AuthBloc>().add(LogoutRequested());
        }
      },
    );
  }

  void _onDeleteAccount(BuildContext context) {
    debugPrint("Show Delete Account Confirmation Dialog");
    AppConfirmationDialog.show(
      context,
      title: 'Delete Account',
      message: 'Are you sure you want to permanently delete your account? All your exam history, bookmarks, and subscriptions will be permanently erased. This action cannot be undone.',
      confirmText: 'Delete Permanently',
      isDestructive: true,
      onConfirm: () {
        debugPrint("Delete account confirmed. Dispatching DeleteAccountRequested to AuthBloc.");
        final globalContext = navigatorKey.currentContext;
        if (globalContext != null) {
          globalContext.read<AuthBloc>().add(DeleteAccountRequested());
        } else {
          context.read<AuthBloc>().add(DeleteAccountRequested());
        }
      },
    );
  }
}

