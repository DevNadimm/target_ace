import 'package:flutter/material.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';

class ProfileSetupFooter extends StatelessWidget {
  final int currentStep;
  final bool isLastStep;
  final String? buttonText;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const ProfileSetupFooter({
    super.key,
    required this.currentStep,
    this.isLastStep = false,
    this.buttonText,
    this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final textToShow = buttonText ?? (isLastStep ? 'SUBMIT' : 'CONTINUE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SpringButton(
          onPressed: onNext,
          child: Text(textToShow),
        ),
      ),
    );
  }
}