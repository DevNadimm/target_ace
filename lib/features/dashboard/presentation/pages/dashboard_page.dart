import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/features/dashboard/data/repos/dashboard_repo.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/components/streak_card.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/active_exam_card.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';
import 'package:target_ace/core/components/custom_divider.dart';
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
  StreamSubscription<void>? _realtimeSubscription;
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
    _realtimeSubscription?.cancel();
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
    _realtimeSubscription = DashboardRepo.dashboardRealtimeChanges.listen((_) {
      if (mounted) {
        context.read<DashboardBloc>().add(DashboardFetchRequested(isSilent: true));
        _loadUserGoal();
      }
    });
  }

  Future<void> _loadUserGoal() async {
    final activeGroup = await AppPreferences.getActiveGroupTitle();
    final goal = await AppPreferences.getUserGoal();
    if (mounted) {
      setState(() {
        _userGoal = (activeGroup != null && activeGroup.isNotEmpty) ? activeGroup : _formatGoal(goal);
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
                        child: ActiveExamCard(
                          exam: data.activeExam,
                          hasSubmitted: data.hasSubmittedActiveExam,
                          userGoal: _userGoal,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daily Streak Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: StreakCard(streakCount: data.stats.streakCount, highestStreak: data.stats.highestStreak),
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
}