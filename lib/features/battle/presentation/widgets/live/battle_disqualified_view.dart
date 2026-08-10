import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';

class BattleDisqualifiedView extends StatelessWidget {
  final String examTitle;
  final VoidCallback onExit;

  const BattleDisqualifiedView({
    super.key,
    required this.examTitle,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Details
                Text(
                  examTitle,
                  style: AppFonts.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Battle terminated.',
                  style: AppFonts.body(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Disqualified Container
                CustomContainer(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedAlert02,
                          color: AppColors.error,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'DISQUALIFIED',
                        style: AppFonts.heading(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.error,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You were disqualified from the battle. Your score has been forfeited and will not appear on the leaderboard.',
                        style: AppFonts.body(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Exit Button
                SizedBox(
                  width: double.infinity,
                  child: SpringButton(
                    backgroundColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    height: 56.0,
                    onPressed: onExit,
                    child: Text(
                      'Back to Home',
                      style: AppFonts.body(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
