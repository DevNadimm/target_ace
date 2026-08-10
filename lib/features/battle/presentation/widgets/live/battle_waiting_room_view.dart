import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/components/info_row.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/features/battle/presentation/widgets/live/battle_countdown_timer.dart';

class BattleWaitingRoomView extends StatefulWidget {
  final String examTitle;
  final ValueNotifier<int> secondsNotifier;

  const BattleWaitingRoomView({
    super.key,
    required this.examTitle,
    required this.secondsNotifier,
  });

  @override
  State<BattleWaitingRoomView> createState() => _BattleWaitingRoomViewState();
}

class _BattleWaitingRoomViewState extends State<BattleWaitingRoomView>
    with TickerProviderStateMixin {
  // Syncing dot + FAB fade
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Avatar entrance
  late AnimationController _avatarEntranceController;
  late Animation<double> _avatarEntranceAnimation;

  // Dynamic join data pool
  static const _avatarPool = [
    (label: 'R', color: Color(0xFF6C63FF)),
    (label: 'A', color: Color(0xFFFF6584)),
    (label: 'M', color: Color(0xFF43B89C)),
    (label: 'S', color: Color(0xFFFF9F43)),
    (label: 'J', color: Color(0xFF2ED573)),
    (label: 'K', color: Color(0xFF1E90FF)),
    (label: 'N', color: Color(0xFFFFA502)),
    (label: 'T', color: Color(0xFFFF4757)),
  ];
  
  final List<({int id, String label, Color color})> _activeAvatars = [];
  int _avatarIdCounter = 0;
  int _poolIndex = 0;
  Timer? _joinTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _avatarEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _avatarEntranceAnimation = CurvedAnimation(
      parent: _avatarEntranceController,
      curve: Curves.easeOutBack,
    );

    // Start dynamic live joining
    _scheduleNextJoin();
  }

  void _scheduleNextJoin() {
    if (!mounted) return;
    
    final random = Random();
    int delayMs;
    final randValue = random.nextDouble();
    
    // Randomize intervals to feel organic
    if (randValue < 0.1) {
      // 10% chance for a long pause (10-30s)
      delayMs = 10000 + random.nextInt(20000);
    } else if (randValue < 0.35) {
      // 25% chance for a medium pause (4-8s)
      delayMs = 4000 + random.nextInt(4000);
    } else {
      // 65% chance for a fast burst (0.5-2.5s)
      delayMs = 500 + random.nextInt(2000);
    }

    _joinTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      setState(() {
        if (_activeAvatars.length >= 4) {
          _activeAvatars.removeAt(0); // keep max 4 avatars visible
        }
        final poolItem = _avatarPool[_poolIndex % _avatarPool.length];
        _activeAvatars.add((id: _avatarIdCounter++, label: poolItem.label, color: poolItem.color));
        _poolIndex++;
      });
      _avatarEntranceController.forward(from: 0);
      _scheduleNextJoin();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _avatarEntranceController.dispose();
    _joinTimer?.cancel();
    super.dispose();
  }

  void _showRulesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top notch
                  Center(
                    child: Container(
                      height: 5,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Header - simple like notification sheet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Battle Rules',
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rules list
                  CustomContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        InfoRow(
                          icon: HugeIcons.strokeRoundedAlertCircle,
                          label: 'Focus Mode',
                          value: 'Leaving the app (>30s) triggers auto-disqualification.',
                        ),
                        const CustomDivider.dotted(),
                        InfoRow(
                          icon: HugeIcons.strokeRoundedClock01,
                          label: 'Time Tracking',
                          value: 'Time spent outside the app is deducted from your total duration.',
                        ),
                        const CustomDivider.dotted(),
                        InfoRow(
                          icon: HugeIcons.strokeRoundedChampion,
                          label: 'No Retakes',
                          value: 'One submission allowed per candidate. Retakes are strictly blocked.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
        leading: ValueListenableBuilder<int>(
          valueListenable: widget.secondsNotifier,
          builder: (context, seconds, _) {
            return seconds > 10 ? const BackButton() : const SizedBox.shrink();
          },
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FadeTransition(
        opacity: _pulseAnimation,
        child: CustomContainer(
          onTap: () => _showRulesBottomSheet(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedInformationCircle,
                color: AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Battle Rules',
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: widget.secondsNotifier,
            builder: (context, waitingSecondsRemaining, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Flame animation
                            Lottie.asset(
                              Assets.flameAnim,
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),

                            // Title
                            Text(
                              widget.examTitle,
                              textAlign: TextAlign.center,
                              style: AppFonts.heading(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              'The room is open. Tonight\'s synced live battle is starting soon. Prepare your mindset!',
                              textAlign: TextAlign.center,
                              style: AppFonts.body(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Live joining avatars
                            _buildLiveJoining(),
                            const SizedBox(height: 32),

                            // Countdown label
                            Text(
                              'BATTLE STARTS IN',
                              style: AppFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Time cards
                            BattleCountdownTimer(secondsRemaining: waitingSecondsRemaining),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLiveJoining() {
    const double avatarSize = 22.0;
    const double overlap = 8.0;
    final totalWidth = avatarSize + (_activeAvatars.isEmpty ? 0 : _activeAvatars.length - 1) * (avatarSize - overlap);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overlapping avatars
        if (_activeAvatars.isNotEmpty)
          SizedBox(
            width: totalWidth,
            height: avatarSize + 4, // +4 for border
            child: Stack(
              clipBehavior: Clip.none,
              children: _activeAvatars.asMap().entries.map((entry) {
                final i = entry.key;
                final avatar = entry.value;
                final isNewest = i == _activeAvatars.length - 1;

                Widget circle = Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: avatar.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatar.label,
                    style: AppFonts.body(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );

                // Animate only the newest avatar pop-in
                if (isNewest) {
                  circle = ScaleTransition(
                    scale: _avatarEntranceAnimation,
                    child: FadeTransition(
                      opacity: _avatarEntranceAnimation,
                      child: circle,
                    ),
                  );
                }

                // Smoothly slide older avatars to the left
                return AnimatedPositioned(
                  key: ValueKey(avatar.id),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  left: i * (avatarSize - overlap),
                  child: circle,
                );
              }).toList(),
            ),
          ),
        if (_activeAvatars.isNotEmpty) const SizedBox(width: 8),
        // Join count + live badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live red dot
            FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              ' Joining live',
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}