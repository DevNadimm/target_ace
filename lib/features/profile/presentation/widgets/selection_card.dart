import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class SelectionCard extends StatefulWidget {
  final String title;
  final String? image;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    this.image,
    required this.isSelected,
    this.isMultiSelect = false,
    required this.onTap,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> {
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
    if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
      return CustomCachedImage(
        imageUrl: imgStr,
        width: 32,
        height: 32,
        borderRadius: 8.0,
        useShimmer: true,
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          imgStr,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(
            width: 32,
            height: 32,
          ),
        ),
      );
    }
  }

  Widget? _buildTrailing() {
    if (widget.isMultiSelect) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 2,
          ),
        ),
        child: widget.isSelected
            ? const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.textOnPrimary,
              )
            : null,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final leading = _buildLeadingImage();
    final trailing = _buildTrailing();

    const double depth = 3.0;
    final double translation = _isPressed ? depth : 0.0;

    // Color definitions for Duolingo 3D style
    final Color resolvedBorderColor = widget.isSelected
        ? AppColors.primary
        : AppColors.inputBorder;

    final Color resolvedShadowColor = widget.isSelected
        ? AppColors.primary
        : AppColors.inputBorder;

    // Solid opaque background colors (prevents underlying stack bleed)
    final Color resolvedFaceColor = widget.isSelected
        ? AppColors.primary10
        : AppColors.cardAlt;

    final Color resolvedTextColor = widget.isSelected
        ? AppColors.primary
        : AppColors.textPrimary;

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
                        child: Text(
                          widget.title,
                          style: AppFonts.body(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: resolvedTextColor,
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing,
                      ],
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
