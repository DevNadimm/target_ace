import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';

class WaitingRoomWidget extends StatelessWidget {
  final String examTitle;
  final int waitingSecondsRemaining;

  const WaitingRoomWidget({
    super.key,
    required this.examTitle,
    required this.waitingSecondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (waitingSecondsRemaining / 60).floor();
    final seconds = waitingSecondsRemaining % 60;
    final minsStr = minutes.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
        leading: waitingSecondsRemaining > 10 ? const BackButton() : null,
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedFire02,
                    color: AppColors.primary,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  examTitle,
                  style: AppFonts.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The room is open. Tonight\'s synced live battle is starting soon. Prepare your mindset!',
                  style: AppFonts.body(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Text(
                  'BATTLE STARTS IN',
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTimeCard(minsStr, 'MINUTES'),
                    _buildTimeSeparator(),
                    _buildTimeCard(secsStr, 'SECONDS'),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Syncing live... Battle starts automatically',
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.cardAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.03),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: AppFonts.heading(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppFonts.body(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: Text(
        ':',
        style: AppFonts.heading(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
