import 'package:flutter/material.dart' hide BackButton;
import 'package:target_ace/core/config/typography.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:target_ace/features/profile/presentation/pages/group_switch_page.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/info_row.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/components/stat_card.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/app_config.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/app_confirmation_dialog.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/features/auth/presentation/pages/login_page.dart';


class ProfilePage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const ProfilePage());

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userGender = '';
  String _userDob = '';
  String _userInstitution = '';
  String _userDistrict = '';
  String _avatarUrl = '';
  String _subscriptionPlanName = '';
  String _subscriptionStatus = '';
  String _subscriptionExpiry = '';
  String _activeGroupTitle = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await AppPreferences.getUserName();
    final email = await AppPreferences.getUserEmail();
    final phone = await AppPreferences.getUserPhone();
    final gender = await AppPreferences.getUserGender();
    final dob = await AppPreferences.getUserDob();
    final institution = await AppPreferences.getUserInstitution();
    final district = await AppPreferences.getUserDistrict();
    final avatarUrl = await AppPreferences.getUserAvatarUrl();
    final planName = await AppPreferences.getSubscriptionPlanName();
    final status = await AppPreferences.getSubscriptionStatus();
    final expiry = await AppPreferences.getSubscriptionExpiryDate();
    final groupTitle = await AppPreferences.getActiveGroupTitle();

    if (!mounted) return;
    setState(() {
      _userName = name;
      _userEmail = email;
      _userPhone = phone;
      _userGender = gender;
      _userDob = dob;
      _userInstitution = institution;
      _userDistrict = district;
      _avatarUrl = avatarUrl;
      _subscriptionPlanName = planName;
      _subscriptionStatus = status;
      _subscriptionExpiry = expiry ?? '';
      _activeGroupTitle = groupTitle.isNotEmpty ? groupTitle : 'Not Selected';
      _isLoading = false;
    });
  }

  String get _statusLabel {
    final expiryDate = DateTime.tryParse(_subscriptionExpiry);
    if (expiryDate != null) {
      final now = DateTime.now();
      if (expiryDate.isBefore(now)) {
        return 'Expired';
      }
    }

    switch (_subscriptionStatus) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'pending_verification':
        return 'Pending Verification';
      case 'trial':
        return 'Trial';
      default:
        return 'No Plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPlanName = _subscriptionPlanName.isNotEmpty ? _subscriptionPlanName : 'No Active Plan';

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: GradientBackground(
        child: _isLoading
            ? const Loader()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileAvatarHeader(
                      userName: _userName,
                      userEmail: _userEmail,
                      avatarUrl: _avatarUrl,
                    ),
                    const SizedBox(height: 16),
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
                          value: _statusLabel,
                          icon: _subscriptionStatus == 'active' ? HugeIcons.strokeRoundedCheckmarkSquare02 : HugeIcons.strokeRoundedAlertSquare,
                          color: _subscriptionStatus == 'active' ? AppColors.success : AppColors.error,
                          isRaw: true,
                        ),
                      ],
                    ),
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
                            icon: HugeIcons.strokeRoundedCall,
                            label: 'Phone',
                            value: _userPhone.isNotEmpty ? _userPhone : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedMail01,
                            label: 'Email',
                            value: _userEmail.isNotEmpty ? _userEmail : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedUser,
                            label: 'Gender',
                            value: _userGender.isNotEmpty ? _userGender : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedCalendar01,
                            label: 'Date of Birth',
                            value: _userDob.isNotEmpty ? DateFormatter.readable(_userDob) : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedSchool,
                            label: 'Institution',
                            value: _userInstitution.isNotEmpty ? _userInstitution : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedLocation01,
                            label: 'District',
                            value: _userDistrict.isNotEmpty ? _userDistrict : 'N/A',
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedTarget01,
                            label: 'Battle Group',
                            value: _activeGroupTitle,
                            onTap: () async {
                              final didSwitch = await Navigator.push(context, GroupSwitchPage.route());
                              if (didSwitch == true) {
                                _loadProfile();
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
                            value: _statusLabel,
                          ),
                          const CustomDivider.dotted(),
                          InfoRow(
                            icon: HugeIcons.strokeRoundedCalendar04,
                            label: 'Expires On',
                            value: _subscriptionExpiry.isNotEmpty ? DateFormatter.readable(_subscriptionExpiry) : 'N/A',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 4),
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
                            onTap: () async {
                              final userName = await AppPreferences.getUserName();
                              final userId = await AppPreferences.getUserId();
                              final plan = await AppPreferences.getSubscriptionPlanName();

                              final message = '''
Assalamu Alaikum,

I am using ${AppConfig.appName} app. I need help with something.

• Name: $userName
• User ID: $userId
• Plan: $plan
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SpringButton(
                      onPressed: () => _onLogout(context),
                      backgroundColor: AppColors.error,
                      shadowColor: Colors.red.shade900,
                      child: const Text('Log Out'),
                    ),
                    const SizedBox(height: 24),
                  ],
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
      if (mounted) {
        AppNotifier.showSnackBar(context, 'Could not open link: $urlString', type: MessageType.error);
      }
    }
  }

  void _onLogout(BuildContext context) {
    AppConfirmationDialog.show(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      isDestructive: true,
      onConfirm: () async {
        await AppPreferences.clearAll();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(context, LoginPage.route(), (_) => false);
      },
    );
  }
}

class _ProfileAvatarHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarUrl;

  const _ProfileAvatarHeader({
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatarUrl.isNotEmpty
            ? CustomCachedImage(
                imageUrl: avatarUrl,
                width: 60,
                height: 60,
                borderRadius: 30,
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: AppFonts.body(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: AppFonts.body(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (userEmail.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: AppFonts.body(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

