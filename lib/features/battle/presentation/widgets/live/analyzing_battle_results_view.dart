import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';

class AnalyzingBattleResultsView extends StatelessWidget {
  final String examTitle;
  final ValueNotifier<int> secondsNotifier;
  final bool isDisqualified;

  const AnalyzingBattleResultsView({
    super.key,
    required this.examTitle,
    required this.secondsNotifier,
    this.isDisqualified = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: secondsNotifier,
      builder: (context, analyzingSecondsRemaining, _) {
        final int mins = analyzingSecondsRemaining ~/ 60;
        final int secs = analyzingSecondsRemaining % 60;
        final String minsStr = mins.toString().padLeft(2, '0');
        final String secsStr = secs.toString().padLeft(2, '0');

        return Scaffold(
          appBar: AppBar(
            title: Text(isDisqualified ? 'Disqualified' : 'Analyzing Results'),
            automaticallyImplyLeading: false,
          ),
          body: GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDisqualified
                            ? AppColors.error.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: isDisqualified
                            ? HugeIcons.strokeRoundedCancel01
                            : HugeIcons.strokeRoundedAnalytics01,
                        color: isDisqualified ? AppColors.error : AppColors.primary,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
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

                    // Status badge
                    if (isDisqualified) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'DISQUALIFIED',
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Subtitle
                    Text(
                      isDisqualified
                          ? 'You left the app during the exam. Your answers have been submitted. Results will be revealed once the battle concludes.'
                          : 'Great effort! Your answers are being processed. Results will be revealed once all participants complete the battle.',
                      style: AppFonts.body(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Countdown label
                    Text(
                      'RESULTS IN',
                      style: AppFonts.body(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDisqualified ? AppColors.error : AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTimeCard(minsStr, 'MINUTES', isDisqualified),
                        _buildTimeSeparator(isDisqualified),
                        _buildTimeCard(secsStr, 'SECONDS', isDisqualified),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Live syncing indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDisqualified ? AppColors.error : AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDisqualified ? AppColors.error : AppColors.primary)
                                    .withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Syncing live... Results display automatically',
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedInformationCircle,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'WHILE YOU WAIT',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            HugeIcons.strokeRoundedUserGroup,
                            'Other participants are still completing their exam. The leaderboard syncs once everyone finishes.',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            HugeIcons.strokeRoundedChampion,
                            'Your rank is calculated based on score and submission time among all participants.',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            HugeIcons.strokeRoundedMedal01,
                            'Stay on this screen â€” results will appear here automatically. No need to refresh.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(dynamic icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: HugeIcon(icon: icon, color: AppColors.primary, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppFonts.body(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard(String value, String label, bool isDisqualified) {
    final color = isDisqualified ? AppColors.error : AppColors.primary;
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
              color: color.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.03),
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
            color: color,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator(bool isDisqualified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: Text(
        ':',
        style: AppFonts.heading(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: isDisqualified ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }
}