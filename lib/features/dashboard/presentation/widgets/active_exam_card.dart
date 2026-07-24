import 'dart:math';
import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';

/// "Knight Arena" card — the gold-knight mascot bleeds off the right edge
/// over a dark radial glow, with exam info + a compact XP-ring stat and
/// CTA on the left. Public API (exam / hasSubmitted / userGoal) unchanged
/// so DashboardPage doesn't need to change.
///
/// NOTE: `Assets.knightMascot` must be a PNG with a TRANSPARENT background
/// — otherwise you'll get a white box instead of the glow bleeding through.
class ActiveExamCard extends StatefulWidget {
  final DashboardExam? exam;
  final bool hasSubmitted;
  final String? userGoal;

  const ActiveExamCard({
    super.key,
    this.exam,
    this.hasSubmitted = false,
    this.userGoal,
  });

  @override
  State<ActiveExamCard> createState() => _ActiveExamCardState();
}

class _ActiveExamCardState extends State<ActiveExamCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final now = DateTime.now();
    final isPast = exam != null &&
        now.isAfter(exam.startTime.add(Duration(minutes: exam.durationMinutes)));

    if (exam == null || isPast) {
      return const _EmptyState();
    }

    return _ActiveState(
      exam: exam,
      hasSubmitted: widget.hasSubmitted,
      userGoal: widget.userGoal,
      pulseController: _pulseController,
    );
  }
}

/// Empty / no-live-exam state — same shell, dormant look, no mascot glow.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CustomContainer(
        borderRadius: BorderRadius.zero,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSword01,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "No battle in the arena",
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Sharpen your skills — the next one is coming.",
                    style: AppFonts.body(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live / upcoming state — the knight arena card itself.
class _ActiveState extends StatelessWidget {
  final DashboardExam exam;
  final bool hasSubmitted;
  final String? userGoal;
  final AnimationController pulseController;

  const _ActiveState({
    required this.exam,
    required this.hasSubmitted,
    required this.userGoal,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isLive = exam.isLive;
    final difference = exam.startTime.difference(now);
    final isWithin15Mins = difference.inSeconds <= 15 * 60;
    final isUpcoming = exam.startTime.isAfter(now);
    final canEnter = isLive || (isUpcoming && isWithin15Mins);
    final accentColor = isLive ? AppColors.labelGreen : AppColors.primary;

    double ringProgress;
    String centerValue;
    String centerUnit;
    if (isLive) {
      final elapsed = now.difference(exam.startTime).inSeconds;
      final total = exam.durationMinutes * 60;
      ringProgress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
      centerValue = "${exam.durationMinutes}";
      centerUnit = "MIN";
    } else {
      const windowSeconds = 15 * 60;
      final remaining = difference.inSeconds;
      ringProgress = remaining <= windowSeconds
          ? (1 - remaining / windowSeconds).clamp(0.0, 1.0)
          : 0.0;
      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      centerValue = "$hours:$minutes";
      centerUnit = "LEFT";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CustomContainer(
        borderRadius: BorderRadius.circular(24),
        padding: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Radial glow behind the knight — green while live, gold otherwise.
            Positioned(
              right: -20,
              top: -30,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.25),
                      accentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Knight mascot — bleeds off the right/bottom edge.
            Positioned(
              right: -14,
              bottom: -10,
              top: 6,
              child: Image.asset(
                Assets.knightMascot,
                height: 176,
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),

            // Diagonal corner ribbon.
            Positioned(
              top: 12,
              right: -26,
              child: _CornerRibbon(
                label: isLive ? "LIVE" : "SOON",
                color: accentColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 128, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: pulseController,
                        builder: (context, child) {
                          final scale = isLive ? 1.0 + (pulseController.value * 0.6) : 1.0;
                          final opacity = isLive ? (1 - pulseController.value * 0.7) : 1.0;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isLive)
                                Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity.clamp(0.0, 1.0),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          isLive ? "BATTLE IN PROGRESS" : "NEXT BATTLE",
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (userGoal != null && userGoal!.isNotEmpty) ...[
                    _TagPill(text: userGoal!, color: accentColor),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    exam.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Compact XP-ring stat.
                      SizedBox(
                        width: 46,
                        height: 46,
                        child: CustomPaint(
                          painter: _RingGaugePainter(
                            progress: ringProgress,
                            trackColor: AppColors.background,
                            fillColor: accentColor,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  centerValue,
                                  style: AppFonts.heading(
                                    fontSize: centerValue.length > 4 ? 8 : 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.0,
                                  ),
                                ),
                                Text(
                                  centerUnit,
                                  style: AppFonts.body(
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SpringButton(
                          height: 39,
                          depth: 3,
                          onPressed: (hasSubmitted || !canEnter)
                              ? null
                              : () => Navigator.push(context, LiveBattlePage.route()),
                          child: Text(
                            hasSubmitted
                                ? "Submitted"
                                : (isLive ? "Enter Arena" : "Get Ready"),
                            style: AppFonts.body(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular gauge — track ring + progress arc, drawn from 12 o'clock.
class _RingGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _RingGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 4;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillColor != fillColor;
  }
}

/// Diagonal corner ribbon — folded-banner look, sits over the top-right
/// corner of the card.
class _CornerRibbon extends StatelessWidget {
  final String label;
  final Color color;

  const _CornerRibbon({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: color,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppFonts.body(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Small rounded "pill" label.
class _TagPill extends StatelessWidget {
  final String text;
  final Color color;

  const _TagPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.body(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}