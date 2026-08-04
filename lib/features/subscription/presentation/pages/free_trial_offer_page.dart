import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/subscription/domain/usecases/activate_free_trial.dart';
import 'package:target_ace/core/components/spring_button.dart';

import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/app_notifier.dart';
import 'package:target_ace/core/utils/enums/message_type.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';

class FreeTrialOfferPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const FreeTrialOfferPage());

  const FreeTrialOfferPage({super.key});

  @override
  State<FreeTrialOfferPage> createState() => _FreeTrialOfferPageState();
}

class _FreeTrialOfferPageState extends State<FreeTrialOfferPage> {
  bool _isProcessing = false;

  Future<void> _onStartTrial() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final userId = await UserLocalDataSource.getUserId();
      final userEmail = await UserLocalDataSource.getUserEmail();

      if (userId.isNotEmpty) {
        final res = await sl<ActivateFreeTrial>()(
          ActivateFreeTrialParams(userId: userId, userEmail: userEmail),
        );

        res.fold(
          (failure) {
            if (mounted) {
              final errorMsg = failure.message.toLowerCase();
              if (errorMsg.contains('already used') || errorMsg.contains('free trial')) {
                AppNotifier.showSnackBar(
                  context,
                  'You have already used your free trial. Each user is allowed only one free trial.',
                  type: MessageType.warning,
                );
              } else {
                AppNotifier.showSnackBar(
                  context,
                  'Failed to activate free trial. Please try again later.',
                  type: MessageType.error,
                );
              }
            }
          },
          (_) {},
        );
      }
    } catch (e) {
      debugPrint("Free Trial Activation error: $e");
    } finally {
      if (mounted) {
        context.read<AppLaunchBloc>().add(const FreeTrialHandled());
      }
    }
  }

  Future<void> _onSkip() async {
    if (_isProcessing) return;
    if (mounted) {
      context.read<AppLaunchBloc>().add(const FreeTrialHandled());
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedDiamond02,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unlock Premium Free',
                  style: AppFonts.heading(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Experience all premium features of TargetAce for 7 days, absolutely free. No card required.',
                  style: AppFonts.body(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 360,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SpringButton(
                  onPressed: _isProcessing ? null : _onStartTrial,
                  child: Text(_isProcessing ? 'ACTIVATING...' : 'START 7-DAY FREE TRIAL'),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _isProcessing ? null : _onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: Text(
                      'MAYBE LATER',
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
}
