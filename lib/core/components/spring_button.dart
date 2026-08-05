import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? borderColor;
  final double depth;
  final BorderRadius borderRadius;
  final double? width;
  final double height;
  final bool isOutlined;

  const SpringButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.shadowColor,
    this.borderColor,
    this.depth = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.width,
    this.height = 50.0,
    this.isOutlined = false,
  });

  /// Factory constructor for outlined variant
  const SpringButton.outlined({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.shadowColor,
    this.borderColor,
    this.depth = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.width,
    this.height = 54.0,
  }) : isOutlined = true;

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    // --- Color resolution ---
    final Color resolvedBorderColor = isDisabled
        ? AppColors.greyDark
        : (widget.borderColor ?? AppColors.primary);

    final Color resolvedFaceColor = isDisabled
        ? AppColors.cardAlt
        : widget.isOutlined
        ? (widget.backgroundColor ?? AppColors.surface)
        : (widget.backgroundColor ?? AppColors.primary);

    final Color resolvedShadowColor = isDisabled
        ? AppColors.greyDark // solid lip color when disabled
        : widget.shadowColor ??
              (widget.isOutlined ? resolvedBorderColor : AppColors.primaryDark);

    final Color resolvedTextColor = isDisabled
        ? AppColors.textLight
        : (widget.isOutlined ? resolvedBorderColor : Colors.white);

    final double activeDepth = widget.depth;
    final double translation = _isPressed ? activeDepth : 0.0;

    // Border for outlined variant or disabled state
    final Border? faceBorder = widget.isOutlined
        ? Border.all(color: resolvedBorderColor, width: 2.0)
        : isDisabled
            ? null // Add side border when disabled
            : null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: widget.width,
        height: widget.height + activeDepth,
        child: Stack(
          children: [
            // 1. Bottom shadow layer (solid 3D base)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: activeDepth,
              child: Container(
                decoration: BoxDecoration(
                  color: resolvedShadowColor,
                  borderRadius: widget.borderRadius,
                  // For outlined: the shadow is the border color
                  border: widget.isOutlined
                      ? Border.all(color: resolvedBorderColor, width: 2.0)
                      : null,
                ),
              ),
            ),

            // 2. Animated button face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOutQuad,
              left: 0,
              right: 0,
              top: translation,
              bottom: activeDepth - translation,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: resolvedFaceColor,
                  borderRadius: widget.borderRadius,
                  border: faceBorder,
                ),
                child: DefaultTextStyle(
                  style: AppFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: resolvedTextColor,
                    letterSpacing: 1.0,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

