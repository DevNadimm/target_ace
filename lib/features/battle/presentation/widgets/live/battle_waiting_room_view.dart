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
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
              final minutes = (waitingSecondsRemaining / 60).floor();
              final seconds = waitingSecondsRemaining % 60;
              final minsStr = minutes.toString().padLeft(2, '0');
              final secsStr = seconds.toString().padLeft(2, '0');

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

                            // Syncing Live
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FadeTransition(
                                  opacity: _pulseAnimation,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.textSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Syncing live... Battle starts automatically',
                                  style: AppFonts.body(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildTimeCard(minsStr, 'MINUTES'),
                                _buildTimeSeparator(),
                                _buildTimeCard(secsStr, 'SECONDS'),
                              ],
                            ),
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

  Widget _buildTimeCard(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomContainer(
          width: 80,
          height: 70,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              value,
              style: AppFonts.heading(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppFonts.body(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: Text(
        ':',
        style: AppFonts.heading(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}