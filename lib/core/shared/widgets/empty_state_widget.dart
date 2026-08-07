import 'package:flutter/material.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/config/typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final bool isCenter;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.isCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    return isCenter ? Center(child: _content()) : _content();
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? _loadEmptyImage(),
          const SizedBox(height: 8),
          Text(
            title ?? AppMessages.emptyTitle,
            style: AppFonts.heading(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            message ?? AppMessages.emptyMessage,
            style: AppFonts.body(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _loadEmptyImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Image.asset(Assets.emptyState, width: double.infinity),
    );
  }
}
