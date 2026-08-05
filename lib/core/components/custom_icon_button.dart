import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color? splashColor;
  final ShapeBorder shape;
  final EdgeInsetsGeometry padding;
  final String? tooltip;
  final bool enabled;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.backgroundColor = AppColors.card,
    this.splashColor,
    this.shape = const CircleBorder(),
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = icon;
    if (icon is HugeIcon) {
      final huge = icon as HugeIcon;
      iconWidget = HugeIcon(
        icon: huge.icon,
        color: huge.color,
        size: iconSize,
        strokeWidth: huge.strokeWidth,
      );
    }

    final button = Material(
      color: backgroundColor,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        splashColor: splashColor,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(size: iconSize),
              child: iconWidget,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}