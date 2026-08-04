import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class SubjectCard extends StatefulWidget {
  final String title;
  final Widget? subtitle;
  final String? image;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    required this.onTap,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Widget? _buildLeadingImage() {
    if (widget.image == null || widget.image!.isEmpty) return null;

    final imgStr = widget.image!.trim();
    return CustomCachedImage(
      imageUrl: imgStr,
      width: 60,
      height: 74,
      borderRadius: 8.0,
      useShimmer: true,
    );
  }



  @override
  Widget build(BuildContext context) {
    final leading = _buildLeadingImage();

    const double depth = 3.0;
    final double translation = _isPressed ? depth : 0.0;

    // Color definitions for Duolingo 3D style
    const Color resolvedBorderColor = AppColors.inputBorder;
    const Color resolvedShadowColor = AppColors.inputBorder;
    const Color resolvedFaceColor = AppColors.cardAlt;
    const Color resolvedTextColor = AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: IntrinsicHeight(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Bottom 3D Lip Base (Fills stack background with top depth offset)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: depth,
                child: Container(
                  decoration: BoxDecoration(
                    color: resolvedShadowColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // 2. Animated Top Face Container (Defines dynamic stack height with minHeight: 56.0)
              AnimatedPadding(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOutQuad,
                padding: EdgeInsets.only(
                  top: translation,
                  bottom: depth - translation,
                ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: resolvedFaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: resolvedBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (leading != null) ...[
                        leading,
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: resolvedTextColor,
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              widget.subtitle!,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
