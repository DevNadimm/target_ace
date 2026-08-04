import 'package:flutter/material.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isAnimated;
  final Color dotColor;
  final Color titleColor;
  
  final String? trailingText;
  final VoidCallback? onTrailingTap;
  final Color? trailingColor;
  final FontWeight trailingFontWeight;
  final Widget? trailingWidget;

  const SectionHeader({
    super.key,
    required this.title,
    this.isAnimated = false,
    this.dotColor = AppColors.primary,
    this.titleColor = AppColors.textPrimary,
    this.trailingText,
    this.onTrailingTap,
    this.trailingColor,
    this.trailingFontWeight = FontWeight.w500,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: AppFonts.body(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: titleColor,
        letterSpacing: 0.8,
      ),
    );

    if (isAnimated) {
      titleWidget = _OneDirectionalFadeWave(
        accentColor: titleColor,
        child: titleWidget,
      );
    }

    Widget? buildTrailing() {
      if (trailingWidget != null) return trailingWidget;
      if (trailingText != null) {
        final textWidget = Text(
          trailingText!,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.body(
            fontSize: 11,
            fontWeight: trailingFontWeight,
            color: trailingColor ?? AppColors.textLight,
          ),
        );

        if (onTrailingTap != null) {
          return GestureDetector(
            onTap: onTrailingTap,
            child: textWidget,
          );
        }
        return textWidget;
      }
      return null;
    }

    final trailing = buildTrailing();

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        if (trailing == null)
          Expanded(child: titleWidget)
        else ...[
          titleWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
          ),
        ],
      ],
    );
  }
}

class _OneDirectionalFadeWave extends StatefulWidget {
  final Widget child;
  final Color accentColor;

  const _OneDirectionalFadeWave({
    required this.child,
    required this.accentColor,
  });

  @override
  State<_OneDirectionalFadeWave> createState() => _OneDirectionalFadeWaveState();
}

class _OneDirectionalFadeWaveState extends State<_OneDirectionalFadeWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final val = _waveController.value;
        final sweepPos = (val / 0.75).clamp(0.0, 1.0);
        final startX = -1.6 + (sweepPos * 3.6);
        final endX = -0.4 + (sweepPos * 3.6);

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.accentColor,
                widget.accentColor.withValues(alpha: 0.35),
                widget.accentColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(startX, 0.0),
              end: Alignment(endX, 0.0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
