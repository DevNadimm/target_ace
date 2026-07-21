import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/presentation/bloc/live_battle_hub_bloc.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';

class LiveBattleHeroCard extends StatelessWidget {
  final LiveBattleHubSuccess state;
  final VoidCallback onRefresh;

  const LiveBattleHeroCard({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTodayExam = state.todayExams.isNotEmpty;
    final bool hasUpcomingExam = state.upcomingExams.isNotEmpty;

    final Map<String, dynamic>? activeExam = hasTodayExam
        ? state.todayExams.first
        : (hasUpcomingExam ? state.upcomingExams.first : null);

    String badgeLabel = 'NO BATTLE';
    String title = 'No Live Battle Scheduled Today';
    bool isLiveNow = false;
    bool isNoExamAtAll = activeExam == null;

    if (activeExam != null) {
      title = activeExam['title'] as String? ?? 'Live Battle Exam';
      final timeStr = activeExam['start_time'] as String? ?? '';
      final durationMins = activeExam['duration_minutes'] as int? ?? 30;

      if (timeStr.isNotEmpty) {
        final startTime = DateTime.parse(timeStr).toLocal();
        final endTime = startTime.add(Duration(minutes: durationMins));
        final now = DateTime.now();

        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          isLiveNow = true;
          badgeLabel = 'LIVE NOW';
        } else if (now.isBefore(startTime)) {
          isLiveNow = false;
          if (startTime.day == now.day && startTime.month == now.month) {
            badgeLabel = 'TODAYS BATTLE';
          } else {
            badgeLabel = 'UPCOMING BATTLE';
          }
        } else {
          isNoExamAtAll = true;
        }
      }
    }

    bool isWithin15Mins = false;
    if (activeExam != null) {
      final timeStr = activeExam['start_time'] as String? ?? '';
      if (timeStr.isNotEmpty) {
        final startTime = DateTime.parse(timeStr).toLocal();
        final diff = startTime.difference(DateTime.now());
        if (diff.inMinutes <= 15) {
          isWithin15Mins = true;
        }
      }
    }
    final bool canEnter = isLiveNow || isWithin15Mins;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.8),
            AppColors.cardAlt,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLiveNow
                      ? AppColors.error
                      : (isNoExamAtAll ? AppColors.grey : AppColors.primary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLiveNow ? Icons.fiber_manual_record : (isNoExamAtAll ? Icons.event_busy : Icons.timer),
                      color: isNoExamAtAll ? AppColors.textSecondary : Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: AppFonts.body(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isNoExamAtAll ? AppColors.textSecondary : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                state.goalId.toUpperCase(),
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppFonts.heading(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          if (activeExam != null)
            LiveBattleCountdownText(
              startTimeStr: activeExam['start_time'] as String? ?? '',
              durationMins: activeExam['duration_minutes'] as int? ?? 30,
              onTimerFinished: onRefresh,
            )
          else
            Text(
              'Check back soon! Live battles are scheduled daily by admins.',
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          if (!isNoExamAtAll) ...[
            const SizedBox(height: 18),
            SpringButton(
              backgroundColor: canEnter ? AppColors.primary : AppColors.greyDark,
              onPressed: canEnter
                  ? () => Navigator.push(context, LiveBattlePage.route())
                  : null,
              child: Center(
                child: Text(
                  isLiveNow ? 'Enter Battle Arena' : 'Enter Waiting Room',
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: canEnter ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            if (!canEnter) ...[
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Waiting room opens 15 minutes before the battle starts.',
                  style: AppFonts.body(
                    fontSize: 11.5,
                    color: AppColors.primaryLight.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class LiveBattleCountdownText extends StatefulWidget {
  final String startTimeStr;
  final int durationMins;
  final VoidCallback? onTimerFinished;

  const LiveBattleCountdownText({
    super.key,
    required this.startTimeStr,
    required this.durationMins,
    this.onTimerFinished,
  });

  @override
  State<LiveBattleCountdownText> createState() => _LiveBattleCountdownTextState();
}

class _LiveBattleCountdownTextState extends State<LiveBattleCountdownText> {
  Timer? _timer;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (widget.startTimeStr.isEmpty) {
      if (mounted) setState(() => _displayText = '');
      return;
    }
    try {
      final startTime = DateTime.parse(widget.startTimeStr).toLocal();
      final endTime = startTime.add(Duration(minutes: widget.durationMins));
      final now = DateTime.now();
      final diff = startTime.difference(now);

      String text = '';
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        text = 'Battle is Live Now!';
      } else if (now.isBefore(startTime)) {
        if (startTime.day == now.day && startTime.month == now.month) {
          final hours = diff.inHours.toString().padLeft(2, '0');
          final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
          final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');
          if (diff.inHours > 0) {
            text = '$hours hrs $mins mins left';
          } else {
            text = '$mins mins $secs secs left';
          }
        } else {
          final formattedDate = DateFormat('dd MMM, hh:mm a').format(startTime);
          if (diff.inDays >= 1) {
            text = '$formattedDate (Starts in ${diff.inDays} days)';
          } else {
            text = '$formattedDate (Starts in ${diff.inHours} hours)';
          }
        }
      } else {
        text = 'Check back soon! Live battles are scheduled daily by admins.';
        widget.onTimerFinished?.call();
      }

      if (mounted) {
        setState(() => _displayText = text);
      }
    } catch (_) {
      if (mounted) setState(() => _displayText = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: AppFonts.body(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryLight,
      ),
    );
  }
}
