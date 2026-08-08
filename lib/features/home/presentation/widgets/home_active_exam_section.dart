import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/home/domain/entities/home_entity.dart';
import 'package:target_ace/features/subscription/presentation/widgets/subscription_paywall_bottom_sheet.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

// Ticket geometry constants
const double _kStubWidth = 84.0;
const double _kNotchRadius = 10.0;
const double _kCornerRadius = 20.0;

class HomeActiveExamSection extends StatelessWidget {
  final HomeExamEntity? exam;
  final bool hasSubmitted;
  final String? userGoal;

  const HomeActiveExamSection({
    super.key,
    this.exam,
    this.hasSubmitted = false,
    this.userGoal,
  });

  @override
  Widget build(BuildContext context) {
    final exam = this.exam;
    final now = DateTime.now();
    final isPast = exam != null &&
        now.isAfter(exam.startTime.add(Duration(minutes: exam.durationMinutes)));

    if (exam == null || isPast) {
      return const _IdleCard();
    }

    return _TicketCard(
      exam: exam,
      hasSubmitted: hasSubmitted,
      userGoal: userGoal,
    );
  }
}

// ─────────────────────────────────────────────────────────
// IDLE
// ─────────────────────────────────────────────────────────

class _IdleCard extends StatelessWidget {
  const _IdleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(_kCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Arena is Quiet',
            style: AppFonts.heading(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'New battles are scheduled daily.',
            style: AppFonts.body(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TICKET CARD
// ─────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final HomeExamEntity exam;
  final bool hasSubmitted;
  final String? userGoal;

  const _TicketCard({
    required this.exam,
    required this.hasSubmitted,
    required this.userGoal,
  });

  Future<void> _onEnter(BuildContext context) async {
    final status = await UserLocalDataSource.getSubscriptionStatus();
    if (!context.mounted) return;
    if (status != 'active' && status != 'trial') {
      SubscriptionPaywallBottomSheet.show(context, status: status);
    } else {
      Navigator.push(context, LiveBattlePage.route());
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isLive = exam.isLive;
    final difference = exam.startTime.difference(now);
    final isWithin15Mins = difference.inSeconds <= 15 * 60;
    final isUpcoming = exam.startTime.isAfter(now);
    final canEnter = isLive || (isUpcoming && isWithin15Mins);
    final canAct = canEnter && !hasSubmitted;

    final Color accent = isLive ? AppColors.success : AppColors.primary;
    final Color accentShadow =
        isLive ? const Color(0xFF047857) : AppColors.primaryDark;

    final String ctaLabel = hasSubmitted
        ? 'Submitted'
        : (isLive ? 'Enter Battle' : 'Get Ready');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Base card (clipped to ticket shape) ──────────────
        ClipPath(
          clipper: _TicketClipper(),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT STUB: accent countdown ───────────────
                Container(
                  width: _kStubWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent,
                        accent.withValues(alpha: 0.80),
                      ],
                    ),
                  ),
                  child: _CountdownStub(
                    startTime: exam.startTime,
                    durationMinutes: exam.durationMinutes,
                    isLive: isLive,
                  ),
                ),

                // ── RIGHT BODY: content ───────────────────────
                Expanded(
                  child: Container(
                    color: AppColors.card,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status label — same language as Arena page
                        Text(
                          isLive ? 'LIVE NOW' : 'UPCOMING BATTLE',
                          style: AppFonts.body(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accent,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Title — Fraunces w400 like Arena
                        Text(
                          exam.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Meta
                        Text(
                          '${exam.durationMinutes} min  ·  ${exam.totalQuestions} questions',
                          style: AppFonts.body(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 14),

                        // CTA
                        SpringButton(
                          height: 42,
                          depth: canAct ? 3 : 0,
                          backgroundColor: canAct ? accent : AppColors.greyDark,
                          shadowColor:
                              canAct ? accentShadow : AppColors.grey,
                          onPressed: canAct ? () => _onEnter(context) : null,
                          child: Text(
                            ctaLabel,
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: canAct
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
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

        // ── Dashed tear-line (drawn over the card) ───────────
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TearLinePainter(),
            ),
          ),
        ),

        // ── Notch circles (use background color to "bite" in) ─
        // Top notch
        Positioned(
          left: _kStubWidth - _kNotchRadius,
          top: -_kNotchRadius,
          child: Container(
            width: _kNotchRadius * 2,
            height: _kNotchRadius * 2,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom notch
        Positioned(
          left: _kStubWidth - _kNotchRadius,
          bottom: -_kNotchRadius,
          child: Container(
            width: _kNotchRadius * 2,
            height: _kNotchRadius * 2,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// COUNTDOWN STUB — left panel
// ─────────────────────────────────────────────────────────

class _CountdownStub extends StatefulWidget {
  final DateTime startTime;
  final int durationMinutes;
  final bool isLive;

  const _CountdownStub({
    required this.startTime,
    required this.durationMinutes,
    required this.isLive,
  });

  @override
  State<_CountdownStub> createState() => _CountdownStubState();
}

class _CountdownStubState extends State<_CountdownStub> {
  Timer? _timer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String _label = '';

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final now = DateTime.now();
    final endTime =
        widget.startTime.add(Duration(minutes: widget.durationMinutes));
    Duration d;
    String lbl;

    if (now.isAfter(widget.startTime) && now.isBefore(endTime)) {
      d = endTime.difference(now);
      lbl = 'LEFT';
    } else if (now.isBefore(widget.startTime)) {
      d = widget.startTime.difference(now);
      lbl = 'UNTIL';
    } else {
      d = Duration.zero;
      lbl = '';
    }

    if (mounted) {
      setState(() {
        _hours = d.inHours;
        _minutes = d.inMinutes % 60;
        _seconds = d.inSeconds % 60;
        _label = lbl;
      });
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget _unit(String val, String lbl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.0,
          ).copyWith(
            fontFeatures: const [ui.FontFeature.tabularFigures()],
          ),
        ),
        Text(
          lbl,
          style: AppFonts.body(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _unit(_pad(_hours), 'HR'),
          const SizedBox(height: 8),
          _unit(_pad(_minutes), 'MIN'),
          const SizedBox(height: 8),
          _unit(_pad(_seconds), 'SEC'),
          if (_label.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _label,
              style: AppFonts.body(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TICKET SHAPE CLIPPER
// ─────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────
// DASHED TEAR LINE
// ─────────────────────────────────────────────────────────

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
