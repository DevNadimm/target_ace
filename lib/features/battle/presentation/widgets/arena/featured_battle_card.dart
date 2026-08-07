import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/utils/helpers/helper_functions.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/presentation/bloc/arena/battle_arena_bloc.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/subscription/presentation/widgets/subscription_paywall_bottom_sheet.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class FeaturedBattleCard extends StatelessWidget {
  final BattleArenaSuccess state;
  final VoidCallback onRefresh;

  const FeaturedBattleCard({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final BattleEntity? activeExam = state.todayExams.isNotEmpty
        ? state.todayExams.first
        : (state.upcomingExams.isNotEmpty ? state.upcomingExams.first : null);

    bool isLiveNow = false;
    bool isNoExamAtAll = activeExam == null;
    bool isWithin15Mins = false;

    if (activeExam != null && activeExam.startTime.isNotEmpty) {
      final startTime = DateTime.parse(activeExam.startTime).toLocal();
      final endTime = startTime.add(
        Duration(minutes: activeExam.durationMinutes),
      );
      final now = DateTime.now();

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        isLiveNow = true;
      } else if (now.isAfter(endTime)) {
        isNoExamAtAll = true;
      }

      final diff = startTime.difference(now);
      if (diff.inMinutes <= 15 && diff.inSeconds >= 0) isWithin15Mins = true;
    }

    final bool canEnter = isLiveNow || isWithin15Mins;

    if (isNoExamAtAll) {
      return const _ArenaIdleCard();
    }

    return _MindPopHero(
      exam: activeExam!,
      isLiveNow: isLiveNow,
      canEnter: canEnter,
      onRefresh: onRefresh,
    );
  }
}

class _MindPopHero extends StatelessWidget {
  final BattleEntity exam;
  final bool isLiveNow;
  final bool canEnter;
  final VoidCallback onRefresh;

  const _MindPopHero({
    required this.exam,
    required this.isLiveNow,
    required this.canEnter,
    required this.onRefresh,
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
    final Color primaryColor = isLiveNow
        ? AppColors.success
        : AppColors.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.2),
            primaryColor.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Stack(
        children: [
          /// Animated Fire Layer
          Positioned.fill(child: _AnimatedFireBackground(color: Colors.white)),

          /// Content Layer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isLiveNow ? 'LIVE NOW' : 'UPCOMING BATTLE',
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 38),
                Text(
                  exam.title.isNotEmpty ? exam.title : 'Battle Exam',
                  textAlign: TextAlign.center,
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${exam.durationMinutes} Minutes  ●  ${(exam.totalQuestions).toInt()} Questions',
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 38),
                _MindPopCountdown(
                  startTimeStr: exam.startTime,
                  durationMins: exam.durationMinutes,
                  primaryColor: Colors.white,
                  isLiveNow: isLiveNow,
                  onTimerFinished: onRefresh,
                ),
                if (canEnter) ...[
                  const SizedBox(height: 38),
                  SpringButton(
                    onPressed: () => _onEnter(context),
                    child: Text(
                      isLiveNow ? 'Enter Battle' : 'Enter Waiting Room',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal Idle Card
class _ArenaIdleCard extends StatelessWidget {
  const _ArenaIdleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.cardAlt.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Arena is Quiet',
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check back soon.\nNew battles are scheduled daily.',
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal Countdown
class _MindPopCountdown extends StatefulWidget {
  final String startTimeStr;
  final int durationMins;
  final Color primaryColor;
  final bool isLiveNow;
  final VoidCallback? onTimerFinished;

  const _MindPopCountdown({
    required this.startTimeStr,
    required this.durationMins,
    required this.primaryColor,
    required this.isLiveNow,
    this.onTimerFinished,
  });

  @override
  State<_MindPopCountdown> createState() => _MindPopCountdownState();
}

class _MindPopCountdownState extends State<_MindPopCountdown> {
  Timer? _timer;
  String _displayText = '';
  String _label = '';
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void didUpdateWidget(covariant _MindPopCountdown old) {
    super.didUpdateWidget(old);
    if (old.startTimeStr != widget.startTimeStr) {
      _hasTriggered = false;
      _update();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    if (widget.startTimeStr.isEmpty) {
      if (mounted) setState(() => _displayText = '');
      return;
    }
    try {
      final startTime = DateTime.parse(widget.startTimeStr).toLocal();
      final endTime = startTime.add(Duration(minutes: widget.durationMins));
      final now = DateTime.now();
      final diff = startTime.difference(now);
      String text;
      String lbl;

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        final remaining = endTime.difference(now);
        final h = HelperFunctions.padNumber(remaining.inHours);
        final m = HelperFunctions.padNumber(remaining.inMinutes % 60);
        final s = HelperFunctions.padNumber(remaining.inSeconds % 60);
        text = '$h : $m : $s';
        lbl = 'REMAINING';
      } else if (now.isBefore(startTime)) {
        if (startTime.day == now.day && startTime.month == now.month) {
          final h = HelperFunctions.padNumber(diff.inHours);
          final m = HelperFunctions.padNumber(diff.inMinutes % 60);
          final s = HelperFunctions.padNumber(diff.inSeconds % 60);
          text = '$h : $m : $s';
          lbl = 'STARTS IN';
        } else {
          text = DateFormat('MMM dd, hh:mm a').format(startTime);
          lbl = 'SCHEDULED FOR';
        }
      } else {
        text = 'ENDED';
        lbl = 'STATUS';
        if (!_hasTriggered) {
          _hasTriggered = true;
          widget.onTimerFinished?.call();
        }
      }

      if (mounted) {
        setState(() {
          _displayText = text;
          _label = lbl;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _displayText = '');
    }
  }

  Widget _buildTimerRow(String text) {
    final parts = text.split(':').map((e) => e.trim()).toList();

    final textStyle = AppFonts.heading(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: widget.primaryColor,
      letterSpacing: 2.0,
      height: 0,
    );

    List<Widget> children = [];
    for (int i = 0; i < parts.length; i++) {
      children.add(
        SizedBox(
          width: 44,
          child: Text(
            parts[i],
            textAlign: TextAlign.center,
            style: textStyle.copyWith(
              fontFeatures: const [ui.FontFeature.tabularFigures()],
            ),
          ),
        ),
      );

      if (i < parts.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(':', style: textStyle),
          ),
        );
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }

  @override
  Widget build(BuildContext context) {
    if (_displayText.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _label,
          style: AppFonts.body(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _displayText.contains(' : ')
              ? _buildTimerRow(_displayText)
              : Text(
                  _displayText,
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: widget.primaryColor,
                    letterSpacing: 2.0,
                    height: 0,
                  ),
                ),
        ),
      ],
    );
  }
}

/// Animated Fire Background
class _AnimatedFireBackground extends StatefulWidget {
  final Color color;

  const _AnimatedFireBackground({required this.color});

  @override
  State<_AnimatedFireBackground> createState() => _AnimatedFireBackgroundState();
}

class _AnimatedFireBackgroundState extends State<_AnimatedFireBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    final rand = math.Random(42);
    _particles = List.generate(35, (index) {
      bool isIcon = index % 5 == 0;
      return _Particle(
        xRatio: rand.nextDouble(),
        yRatio: rand.nextDouble(),
        speedY: (3 + rand.nextInt(8)).toDouble(),
        xCycles: (2 + rand.nextInt(6)).toDouble(),
        size: isIcon
            ? (15 + rand.nextDouble() * 10)
            : (2 + rand.nextDouble() * 5),
        opacity: 0.05 + rand.nextDouble() * 0.15,
        isIcon: isIcon,
        phase: rand.nextDouble() * 2 * math.pi,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildParticlePositioned(_Particle p, double width, double height) {
    double currentYRatio = p.yRatio - (_controller.value * p.speedY);
    currentYRatio = currentYRatio - currentYRatio.floorToDouble();
    double currentXRatio = p.xRatio + math.sin(_controller.value * 2 * math.pi * p.xCycles + p.phase) * 0.05;
    currentXRatio = currentXRatio - currentXRatio.floorToDouble();

    final y = currentYRatio * height;
    final x = currentXRatio * width;

    final fadeRatio = currentYRatio;
    final dynamicOpacity = p.opacity * fadeRatio;
    final dynamicSize = p.size * (0.3 + 0.7 * fadeRatio);

    Widget particleWidget;
    if (p.isIcon) {
      particleWidget = HugeIcon(
        icon: HugeIcons.strokeRoundedFire02,
        size: dynamicSize,
        color: widget.color.withValues(alpha: dynamicOpacity),
      );
    } else {
      particleWidget = Container(
        width: dynamicSize,
        height: dynamicSize,
        decoration: BoxDecoration(
          color: widget.color.withValues(
            alpha: dynamicOpacity + 0.1 * fadeRatio,
          ),
          shape: BoxShape.circle,
        ),
      );
    }

    return Positioned(
      left: x - dynamicSize / 2,
      top: y - dynamicSize / 2,
      child: particleWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final icons = _particles.where((p) => p.isIcon).toList();
          final sparks = _particles.where((p) => !p.isIcon).toList();

          return Stack(
            children: [
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: sparks.map((p) => _buildParticlePositioned(p, width, height)).toList(),
                      ),
                    );
                  },
                ),
              ),
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        children: icons.map((p) => _buildParticlePositioned(p, width, height)).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  final double xRatio;
  final double yRatio;
  final double speedY;
  final double xCycles;
  final double size;
  final double opacity;
  final bool isIcon;
  final double phase;

  _Particle({
    required this.xRatio,
    required this.yRatio,
    required this.speedY,
    required this.xCycles,
    required this.size,
    required this.opacity,
    required this.isIcon,
    required this.phase,
  });
}

