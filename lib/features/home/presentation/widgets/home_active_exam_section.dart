import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/home/domain/entities/home_entity.dart';
import 'package:target_ace/features/subscription/presentation/widgets/subscription_paywall_bottom_sheet.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:shimmer/shimmer.dart';

part 'active_exam_components/ticket_skeleton.dart';
part 'active_exam_components/idle_card.dart';
part 'active_exam_components/ticket_card.dart';
part 'active_exam_components/pulse_text.dart';
part 'active_exam_components/countdown_stub.dart';
part 'active_exam_components/ticket_painters.dart';

// Ticket geometry constants
const double _kStubWidth = 84.0;
const double _kNotchRadius = 10.0;
const double _kCornerRadius = 20.0;

class HomeActiveExamSection extends StatelessWidget {
  final HomeExamEntity? exam;
  final bool hasSubmitted;
  final String? userGoal;
  final bool isLoading;

  const HomeActiveExamSection({
    super.key,
    this.exam,
    this.hasSubmitted = false,
    this.userGoal,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ── Skeleton shimmer while loading ──
    if (isLoading) {
      return const _TicketSkeleton();
    }

    final exam = this.exam;
    final now = DateTime.now();
    final isPast = exam != null &&
        now.isAfter(exam.startTime.add(Duration(minutes: exam.durationMinutes)));

    if (exam == null || isPast) {
      return const SizedBox.shrink();
    }

    final content = _TicketCard(
      exam: exam,
      hasSubmitted: hasSubmitted,
      userGoal: userGoal,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}
