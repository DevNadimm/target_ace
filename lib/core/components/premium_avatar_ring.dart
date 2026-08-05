import 'package:flutter/material.dart';
import 'package:target_ace/core/config/colors.dart';

class PremiumAvatarRing extends StatelessWidget {
  final Widget child;
  final double size;
  final bool isPremium;
  final double borderWidth;
  final double padding;

  const PremiumAvatarRing({
    super.key,
    required this.child,
    required this.size,
    required this.isPremium,
    this.borderWidth = 2.5,
    this.padding = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) {
      return SizedBox(
        width: size,
        height: size,
        child: child,
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFF4285F4), // Google Blue
            Color(0xFFEA4335), // Google Red
            Color(0xFFFBBC05), // Google Yellow
            Color(0xFF34A853), // Google Green
            Color(0xFF4285F4), // Wrap around to Blue
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipOval(child: child),
      ),
    );
  }
}