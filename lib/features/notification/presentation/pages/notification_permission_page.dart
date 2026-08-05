import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/notification_service.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';

class NotificationPermissionPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const NotificationPermissionPage());

  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() => _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage> {
  bool _isProcessing = false;

  Future<void> _onTurnOnNotifications() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await sl<NotificationService>().requestPermission();
    } catch (e) {
      debugPrint("Notification permission request error: $e");
    } finally {
      await UserLocalDataSource.setHasPromptedNotification(true);
    }
    
    if (!mounted) return;
    context.read<AppLaunchBloc>().add(const NotificationPermissionHandled());
  }

  Future<void> _onSkip() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    await UserLocalDataSource.setHasPromptedNotification(true);
    if (!mounted) return;
    context.read<AppLaunchBloc>().add(const NotificationPermissionHandled());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
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
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotificationSnooze01,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Get Notified',
                  style: AppFonts.heading(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep up with battle reminders, streak updates, and rank changes from your peers.',
                  style: AppFonts.body(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                                Colors.transparent,
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(36),
                                  border: Border.all(
                                    width: 1,
                                    color: AppColors.cardAlt.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Container(
                                  height: height * 0.45,
                                  width: width * 0.75,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(34),
                                    border: Border.all(width: 12, color: AppColors.cardAlt),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 24,
                                child: Container(
                                  width: 90,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardAlt,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNotificationCard(
                                icon: HugeIcons.strokeRoundedSword01,
                                iconColor: AppColors.primary,
                                iconBgColor: AppColors.primary.withValues(alpha: 0.15),
                                title: 'BCS Daily Battle #8',
                                subtitle: 'Starts in 15 minutes! Get ready.',
                                time: '2m ago',
                                timeColor: AppColors.primary,
                              ),
                              _buildNotificationCard(
                                icon: HugeIcons.strokeRoundedFire03,
                                iconColor: AppColors.warning,
                                iconBgColor: AppColors.warning.withValues(alpha: 0.15),
                                title: '3-Day Streak Active! ðŸ”¥',
                                subtitle: 'You completed today\'s practice drill.',
                                time: '1h ago',
                                timeColor: AppColors.textLight,
                              ),
                              _buildNotificationCard(
                                icon: HugeIcons.strokeRoundedChampion,
                                iconColor: AppColors.success,
                                iconBgColor: AppColors.success.withValues(alpha: 0.15),
                                title: 'Rank Update ðŸ†',
                                subtitle: 'You moved up to #2 in BCS group!',
                                time: '2h ago',
                                timeColor: AppColors.textLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SpringButton(
                  onPressed: _isProcessing ? null : _onTurnOnNotifications,
                  child: Text(_isProcessing ? 'TURNING ON...' : 'ENABLE NOTIFICATIONS'),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _isProcessing ? null : _onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: Text(
                      'NOT NOW',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required dynamic icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String time,
    required Color timeColor,
  }) {
    return CustomContainer(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.body(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}