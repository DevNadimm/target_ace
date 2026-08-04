import 'package:flutter/material.dart';

class FloatingPanel extends StatelessWidget {
  final double size;
  final double rotation;
  final Color color;
  final bool glow;

  const FloatingPanel({
    super.key,
    required this.size,
    required this.rotation,
    required this.color,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
      ),
    );
  }
}
