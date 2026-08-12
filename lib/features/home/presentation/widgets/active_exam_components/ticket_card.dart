part of '../home_active_exam_section.dart';

class _TicketCard extends StatefulWidget {
  final HomeExamEntity exam;
  final bool hasSubmitted;
  final String? userGoal;

  const _TicketCard({
    required this.exam,
    required this.hasSubmitted,
    required this.userGoal,
  });

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<_TicketCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final Animation<double> _ripAnimation = CurvedAnimation(
    parent: _ripController,
    curve: Curves.easeInCubic,
  );

  bool _isRipping = false;
  bool _isNavigating = false;
  Timer? _periodicTimer;
  Timer? _navigationTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Rebuild every second to keep the current time fresh for "isLive", "canEnter", etc.
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _navigationTimer?.cancel();
    _ripController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRipSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/battle_enter.wav'));
    } catch (e, stackTrace) {
      debugPrint('Error playing rip sound: $e\n$stackTrace');
    }
  }

  Future<void> _onEnter(BuildContext context) async {
    if (_isNavigating) return;
    _isNavigating = true;

    HapticFeedback.mediumImpact();
    final status = await UserLocalDataSource.getSubscriptionStatus();
    if (!context.mounted) {
      _isNavigating = false;
      return;
    }
    if (status != 'active' && status != 'trial') {
      SubscriptionPaywallBottomSheet.show(context, status: status);
      _isNavigating = false;
      return;
    }

    // ── Play rip animation + sound, then navigate ──
    setState(() => _isRipping = true);
    _playRipSound();
    await _ripController.forward();

    // Ektu time niye
    await Future.delayed(const Duration(milliseconds: 600));

    if (!context.mounted) {
      _isNavigating = false;
      return;
    }
    Navigator.push(context, LiveBattlePage.route());
    // Reset animation after navigation (for when user comes back)
    _navigationTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _ripController.reset();
        setState(() {
          _isRipping = false;
          _isNavigating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isLive = widget.exam.isLive;
    final difference = widget.exam.startTime.difference(now);
    final isWithin15Mins = difference.inSeconds <= 15 * 60;
    final isUpcoming = widget.exam.startTime.isAfter(now);
    final canEnter = isLive || (isUpcoming && isWithin15Mins);
    final canAct = canEnter && !widget.hasSubmitted;

    final Color accent = isLive ? AppColors.error : AppColors.primary;
    final Color accentShadow = isLive ? AppColors.errorDark : AppColors.primaryDark;

    final String ctaLabel = widget.hasSubmitted
        ? 'Submitted'
        : (isLive ? 'Enter Battle' : 'Get Ready');

    return AnimatedBuilder(
      animation: _ripAnimation,
      builder: (context, child) {
        final ripValue = _ripAnimation.value;
        // Phase 1: Zipper opens (0.0 to 0.5)
        final zipValue = (ripValue * 2).clamp(0.0, 1.0);
        // Phase 2: Slide apart and fade out (0.5 to 1.0)
        final slideValue = ((ripValue - 0.5) * 2).clamp(0.0, 1.0);

        // ── Left stub widget ──
        final leftStub = Transform(
          alignment: Alignment.bottomRight,
          transform: Matrix4.translationValues(
                  -slideValue * 120, 0.0, 0.0)
              ..rotateZ(-zipValue * 0.2),
          child: Opacity(
            opacity: (1.0 - slideValue).clamp(0.0, 1.0),
            child: ClipPath(
              clipper: _LeftStubClipper(),
              child: Container(
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
                  startTime: widget.exam.startTime,
                  durationMinutes: widget.exam.durationMinutes,
                  isLive: isLive,
                ),
              ),
            ),
          ),
        );

        // ── Right body widget ──
        final rightBody = Transform(
          alignment: Alignment.bottomLeft,
          transform: Matrix4.translationValues(
                  slideValue * 120, 0.0, 0.0)
              ..rotateZ(zipValue * 0.2),
          child: Opacity(
            opacity: (1.0 - slideValue).clamp(0.0, 1.0),
            child: ClipPath(
              clipper: _RightBodyClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status label
                    if (isLive)
                      _PulseText(
                        text: '● LIVE NOW',
                        style: AppFonts.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 1.5,
                        ),
                      )
                    else
                      Text(
                        'UPCOMING BATTLE',
                        style: AppFonts.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: 1.5,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      widget.exam.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Meta
                    Text(
                      '${widget.exam.durationMinutes} min  ·  ${widget.exam.totalQuestions} questions',
                      style: AppFonts.body(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),

                    const Spacer(),

                    const SizedBox(height: 16),

                    // CTA
                    SpringButton(
                      height: 39,
                      depth: canAct ? 3 : 0,
                      backgroundColor:
                      canAct ? accent : const Color(0xFFE0E0E0),
                      shadowColor: canAct
                          ? accentShadow
                          : const Color(0xFFBDBDBD),
                      onPressed:
                      canAct ? () => _onEnter(context) : null,
                      child: Text(
                        ctaLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final rowContent = IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leftStub,
              Expanded(child: rightBody),
            ],
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Base card ──
              // Normal state: full ticket clip (rounded + notches)
              // Ripping state: each half already has its own ClipRRect
              _isRipping
                  ? rowContent
                  : ClipPath(
                      clipper: _TicketClipper(),
                      child: rowContent,
                    ),

              // ── "COMPLETED" stamp overlay ──────────────────────────
              if (widget.hasSubmitted)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipPath(
                      clipper: _TicketClipper(),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.18, // slight tilt
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.7),
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'COMPLETED',
                              style: AppFonts.body(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success.withValues(alpha: 0.6),
                                letterSpacing: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Dashed tear-line (drawn over the card) ───────────
              if (!_isRipping)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _TearLinePainter(),
                    ),
                  ),
                ),

              // ── Notch circles (use background color to "bite" in) ─
              if (!_isRipping) ...[
                // Top notch
                Positioned(
                  left: _kStubWidth - _kNotchRadius,
                  top: -_kNotchRadius,
                  child: Container(
                    width: _kNotchRadius * 2,
                    height: _kNotchRadius * 2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

