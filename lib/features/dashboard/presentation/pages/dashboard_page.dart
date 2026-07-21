import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/features/battle/presentation/pages/live_battle_page.dart';
import 'package:target_ace/features/dashboard/presentation/pages/main_navigation_page.dart';
import 'package:target_ace/features/battle/presentation/pages/exam_leaderboard_page.dart';

class DashboardPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const DashboardPage());

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userGoal = '';
  RealtimeChannel? _examsChannel;
  RealtimeChannel? _submissionsChannel;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _loadUserGoal();
    context.read<DashboardBloc>().add(DashboardFetchRequested());
    _setupRealtimeSubscriptions();
    _startStatusTimer();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    if (_examsChannel != null) {
      Supabase.instance.client.removeChannel(_examsChannel!);
    }
    if (_submissionsChannel != null) {
      Supabase.instance.client.removeChannel(_submissionsChannel!);
    }
    super.dispose();
  }

  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _setupRealtimeSubscriptions() {
    final client = Supabase.instance.client;

    _examsChannel = client.channel('public-exams-dashboard')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'exams',
        callback: (payload) {
          if (mounted) {
            context.read<DashboardBloc>().add(DashboardFetchRequested(isSilent: true));
            _loadUserGoal();
          }
        },
      );
    _examsChannel!.subscribe();

    _submissionsChannel = client.channel('public-submissions-dashboard')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'exam_submissions',
        callback: (payload) {
          if (mounted) {
            context.read<DashboardBloc>().add(DashboardFetchRequested(isSilent: true));
          }
        },
      );
    _submissionsChannel!.subscribe();
  }

  Future<void> _loadUserGoal() async {
    final activeGroup = await AppPreferences.getActiveGroupTitle();
    final goal = await AppPreferences.getUserGoal();
    if (mounted) {
      setState(() {
        _userGoal = activeGroup.isNotEmpty ? activeGroup : _formatGoal(goal);
      });
    }
  }

  String _formatGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'bcs':
        return 'BCS & Gov Jobs';
      case 'admission':
        return 'DU & Admission';
      case 'hsc':
        return 'HSC Exam Board';
      default:
        return 'General target';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardAppBar(),
      body: GradientBackground(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: Loader());
            }

            if (state is DashboardFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    state.message ?? 'Failed to load dashboard data. Please try again.',
                    style: AppFonts.body(
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is DashboardSuccess) {
              final data = state.dashboardModel;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(DashboardFetchRequested());
                  await _loadUserGoal();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target & Active Exam Block
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildActiveExamCard(data.activeExam, data.hasSubmittedActiveExam),
                      ),
                      const SizedBox(height: 16),

                      // Daily Streak Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStreakCard(data.stats.streakCount, data.stats.highestStreak),
                      ),
                      const SizedBox(height: 24),

                      // Leaderboard Section Preview
                      if (data.leaderboard.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildLeaderboardPreview(data.leaderboard, data.lastExamTitle, data.lastExamId),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Quick Actions Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Preparation & Practice",
                          style: AppFonts.body(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const QuickActionsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildActiveExamCard(DashboardExam? exam, bool hasSubmitted) {
    if (exam == null) {
      return CustomContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "YOUR TARGET",
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _userGoal,
                    style: AppFonts.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "No live battle exams right now",
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Check back later for updates or review your preparation topics below.",
              style: AppFonts.body(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final isLive = exam.isLive;
    final now = DateTime.now();
    final difference = exam.startTime.difference(now);
    final isWithin15Mins = difference.inSeconds <= 15 * 60;
    final isUpcoming = exam.startTime.isAfter(now);
    final canEnter = isLive || (isUpcoming && isWithin15Mins);

    String countdownText = '';
    if (isUpcoming) {
      final hours = difference.inHours.toString().padLeft(2, '0');
      final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
      countdownText = 'Battle in: $hours hrs : $minutes mins';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.card.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAnalytics01,
              color: AppColors.primary.withValues(alpha: 0.05),
              size: 110,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLive ? "LIVE NOW" : "UPCOMING BATTLE",
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLive ? AppColors.labelGreen : AppColors.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isLive ? AppColors.labelGreen : AppColors.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _userGoal,
                        style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLive ? AppColors.labelGreen : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  exam.title,
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLive
                          ? "Duration: ${exam.durationMinutes} minutes"
                          : countdownText,
                      style: AppFonts.body(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: isUpcoming ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SpringButton(
                  onPressed: (hasSubmitted || !canEnter)
                      ? null
                      : () {
                          Navigator.push(context, LiveBattlePage.route());
                        },
                  backgroundColor: (hasSubmitted || !canEnter)
                      ? AppColors.grey.withValues(alpha: 0.2)
                      : (isLive ? AppColors.labelGreen : AppColors.primary),
                  height: 50.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      hasSubmitted
                          ? "Submitted"
                          : (isLive ? "Join Battle" : "Enter Waiting Room"),
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (hasSubmitted || !canEnter) ? AppColors.textSecondary : Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isUpcoming && !isWithin15Mins && !hasSubmitted) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Waiting room opens 15 minutes before the battle starts.",
                      style: AppFonts.body(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildLeaderboardPreview(List<LeaderboardItem> list, String? lastExamTitle, String? lastExamId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.accentYellow,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  lastExamTitle != null ? 'LAST BATTLE · $lastExamTitle' : 'LAST BATTLE · Top Rank Preview',
                  style: AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentYellow,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final row in list) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Rank Container
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: row.rank == 1
                          ? AppColors.accentYellow.withValues(alpha: 0.15)
                          : row.rank == 2
                              ? AppColors.textSecondary.withValues(alpha: 0.15)
                              : const Color(0xFFCD7F32).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: row.rank == 1
                          ? const HugeIcon(
                              icon: HugeIcons.strokeRoundedCrown,
                              color: AppColors.accentYellow,
                              size: 14,
                            )
                          : Text(
                              '${row.rank}',
                              style: AppFonts.body(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: row.rank == 2
                                    ? AppColors.textSecondary
                                    : const Color(0xFFCD7F32),
                                height: 1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Avatar
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: row.isCurrentUser ? AppColors.primary : AppColors.divider.withValues(alpha: 0.5),
                        width: row.isCurrentUser ? 1.5 : 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: row.avatarUrl != null && row.avatarUrl!.isNotEmpty
                          ? CustomCachedImage(
                              imageUrl: row.avatarUrl!,
                              width: 28,
                              height: 28,
                              borderRadius: 14,
                            )
                          : Container(
                              color: (row.isCurrentUser ? AppColors.primary : AppColors.grey).withValues(alpha: 0.15),
                              child: Center(
                                child: Text(
                                  row.name.isNotEmpty ? row.name[0].toUpperCase() : 'S',
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: row.isCurrentUser ? AppColors.primary : AppColors.textLight,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // User Name
                  Expanded(
                    child: Text(
                      row.name,
                      style: AppFonts.body(
                        fontSize: 13.5,
                        fontWeight: row.isCurrentUser ? FontWeight.bold : FontWeight.w500,
                        color: row.isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score
                  Text(
                    '${row.score.round()}/100',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          CustomDivider.dotted(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Keep practicing to rank on the live board!',
                  style: AppFonts.body(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (lastExamId != null) {
                    Navigator.push(
                      context,
                      ExamLeaderboardPage.route(
                        examId: lastExamId,
                        examTitle: lastExamTitle ?? 'Last Battle',
                      ),
                    );
                  } else {
                    context.findAncestorStateOfType<MainNavigationPageState>()?.setIndex(2);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Full',
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streakCount, int highestStreak) {
    return CustomContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CURRENT STREAK",
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$streakCount",
                        style: AppFonts.heading(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "🔥",
                        style: AppFonts.heading(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Day${streakCount == 1 ? "" : "s"} Streak",
                    style: AppFonts.body(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Lottie.asset(
                  Assets.flameAnim,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const HugeIcon(
                      icon: HugeIcons.strokeRoundedFire,
                      color: AppColors.primary,
                      size: 96,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < streakCount;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == 6 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < streakCount;
              final dayNum = index + 1;
              return _buildCalendarDayBlock(dayNum, isCompleted);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDayBlock(int day, bool isCompleted) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.divider.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 3,
              height: 7,
              decoration: BoxDecoration(
                color: isCompleted ? activeColor : AppColors.textLight.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 3,
              height: 7,
              decoration: BoxDecoration(
                color: isCompleted ? activeColor : AppColors.textLight.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -3),
          child: Container(
            width: 36,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted ? activeColor.withValues(alpha: 0.5) : inactiveColor,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isCompleted ? activeColor : AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        "$day",
                        style: AppFonts.body(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? activeColor : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
