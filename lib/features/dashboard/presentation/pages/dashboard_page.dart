import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/active_exam_card.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/latest_performance_card.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/streak_card.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class DashboardPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (_) => const DashboardPage());

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
    _realtimeSubscription = sl<DashboardRepository>().dashboardRealtimeChanges
        .listen((_) {
          if (mounted) {
            context.read<DashboardBloc>().add(
              DashboardFetchRequested(isSilent: true),
            );
            _loadUserGoal();
          }
        });
  }

  Future<void> _loadUserGoal() async {
    final activeGroup = await UserLocalDataSource.getUserGroupTitle();
    final goal = await UserLocalDataSource.getUserGoal();
    if (mounted) {
      setState(() {
        _userGoal = (activeGroup != null && activeGroup.isNotEmpty)
            ? activeGroup
            : _formatGoal(goal);
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        int unreadCount = 0;
        bool isPremium = false;
        if (state is DashboardSuccess) {
          unreadCount = state.dashboardModel.stats.unreadNotificationsCount;
          isPremium = state.dashboardModel.isPremium;
        }

        return Scaffold(
          appBar: DashboardAppBar(
            unreadNotificationsCount: unreadCount,
            isPremium: isPremium,
          ),
          body: GradientBackground(child: _buildBodyContent(context, state)),
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, DashboardState state) {
    if (state is DashboardLoading) {
      return const Center(child: Loader());
    }

    if (state is DashboardFailure) {
      return ErrorStateWidget(
        errorType: state.errorType,
        message: state.message,
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
              const SizedBox(height: 20),

              // Daily Streak Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreakCard(
                  streakCount: data.stats.streakCount,
                  highestStreak: data.stats.highestStreak,
                  weeklyActiveDays: data.stats.weeklyActiveDays,
                ),
              ),
              const SizedBox(height: 20),

              // Latest Performance Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LatestPerformanceCard(
                  data: data.latestPerformance == null
                      ? null
                      : LatestPerformanceModel(
                          examTitle: data.latestPerformance!.examTitle,
                          completedAt: data.latestPerformance!.completedAt,
                          score: data.latestPerformance!.score,
                          scoreOutOf: data.latestPerformance!.scoreOutOf,
                          accuracy: data.latestPerformance!.accuracy,
                          rank: data.latestPerformance!.rank,
                          totalParticipants:
                              data.latestPerformance!.totalParticipants,
                          timeTaken: data.latestPerformance!.timeTaken,
                        ),
                  onViewAnalysis: () {},
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Section
              const QuickActionsSection(),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
