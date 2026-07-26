import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/components/custom_icon_button.dart';

class BackButton extends StatelessWidget {
  final VoidCallback? onBack;
  final Color backgroundColor;

  const BackButton({
    super.key,
    this.onBack,
    this.backgroundColor = AppColors.card,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: CustomIconButton(
        backgroundColor: backgroundColor,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft02,
          color: AppColors.textPrimary,
        ),
        onTap: onBack ?? () => Navigator.pop(context),
      ),
    );
  }
}
