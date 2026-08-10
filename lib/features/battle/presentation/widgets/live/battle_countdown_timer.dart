import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class BattleCountdownTimer extends StatelessWidget {
  final int secondsRemaining;

  const BattleCountdownTimer({
    super.key,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (secondsRemaining / 60).floor();
    final seconds = secondsRemaining % 60;
    final minsStr = minutes.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTimeCard(minsStr),
        _buildTimeSeparator(),
        _buildTimeCard(secsStr),
      ],
    );
  }

  Widget _buildTimeCard(String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          width: 80,
          height: 70,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              value,
              style: AppFonts.heading(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
      child: Text(
        ':',
        style: AppFonts.heading(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
