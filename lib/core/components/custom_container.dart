import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:target_ace/core/config/colors.dart';

class CustomContainer extends StatefulWidget {
  final Widget child;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final double depth;
  final bool showBorder;

  const CustomContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.gradient,
    this.boxShadow,
    this.depth = 4.0,
    this.showBorder = true,
  });

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    widget.onTap!();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null;
    final borderRadius = widget.borderRadius ?? const BorderRadius.all(Radius.circular(16));

    final double translation = _isPressed ? widget.depth : 0.0;

    Color effectiveBorderColor = widget.borderColor ?? AppColors.inputBorder;
    if (widget.borderColor == null && widget.color != null) {
      final hsl = HSLColor.fromColor(widget.color!);
      effectiveBorderColor = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    }

    Widget content = Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom Shadow Lip
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: widget.depth,
          child: Container(
            decoration: BoxDecoration(
              color: effectiveBorderColor,
              borderRadius: borderRadius,
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.01),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
            ),
          ),
        ),

        // Animated Top Face
        AnimatedPadding(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOutQuad,
          padding: EdgeInsets.only(
            top: translation,
            bottom: widget.depth - translation,
          ),
          child: Container(
            height: widget.height != null
                ? (widget.height! - widget.depth > 0 ? widget.height! - widget.depth : null)
                : null,
            width: widget.width,
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.cardAlt,
              gradient: widget.gradient,
              borderRadius: borderRadius,
              border: widget.showBorder ? Border.all(width: 1.5, color: effectiveBorderColor) : null,
            ),
            child: widget.child,
          ),
        ),
      ],
    );

    // Apply margin on the outside of the stack
    if (widget.margin != null) {
      content = Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    if (isInteractive) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}