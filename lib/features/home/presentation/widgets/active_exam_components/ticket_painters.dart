part of '../home_active_exam_section.dart';

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = _kCornerRadius;
    const nr = _kNotchRadius;
    const sx = _kStubWidth; // split x

    final path = Path();

    // Top-left corner
    path.moveTo(r, 0);
    path.lineTo(sx - nr, 0);
    // Top notch — curves INTO card (clockwise = downward)
    path.arcToPoint(
      Offset(sx + nr, 0),
      radius: const Radius.circular(nr),
      clockwise: true,
    );
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: const Radius.circular(r));
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: const Radius.circular(r),
    );
    path.lineTo(sx + nr, size.height);
    // Bottom notch — curves INTO card (counter-clockwise = upward)
    path.arcToPoint(
      Offset(sx - nr, size.height),
      radius: const Radius.circular(nr),
      clockwise: false,
    );
    path.lineTo(r, size.height);
    path.arcToPoint(
      Offset(0, size.height - r),
      radius: const Radius.circular(r),
    );
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: const Radius.circular(r));
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}




class _TearLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const x = _kStubWidth;
    const dashH = 5.0;
    const dashGap = 4.0;
    const startY = _kNotchRadius * 2;
    final endY = size.height - _kNotchRadius * 2;

    final paint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    double y = startY;
    while (y < endY) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + dashH).clamp(y, endY)), paint);
      y += dashH + dashGap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
