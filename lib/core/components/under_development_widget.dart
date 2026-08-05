import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class UnderDevelopmentWidget extends StatelessWidget {
  final String title;
  final String message;

  const UnderDevelopmentWidget({
    super.key,
    this.title = 'Under Development',
    this.message = 'This feature is currently being built and will be available soon!',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/illustrations/development.svg',
              height: 200,
              // If the SVG doesn't look right due to color overrides, you might remove this colorFilter
              // or ensure the SVG itself uses currentColor. Usually illustrations are multi-colored.
              // So I will not add colorFilter here for now.
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: AppFonts.heading(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppFonts.body(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}