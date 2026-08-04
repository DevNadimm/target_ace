import 'package:flutter/material.dart';

class FadeWaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeWaveAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<FadeWaveAnimation> createState() => _FadeWaveAnimationState();
}

class _FadeWaveAnimationState extends State<FadeWaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: widget.duration,
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
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.3),
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(startX, 0.0),
              end: Alignment(endX, 0.0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
