import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/home/domain/repository/home_repository.dart';
import 'package:target_ace/features/home/presentation/bloc/home_bloc.dart';
import 'package:target_ace/features/home/presentation/widgets/home_active_exam_section.dart';
import 'package:target_ace/features/home/presentation/widgets/home_app_bar.dart';
import 'package:target_ace/features/home/presentation/widgets/home_latest_performance_section.dart';
import 'package:target_ace/features/home/presentation/widgets/home_quick_actions_section.dart';
import 'package:target_ace/features/home/presentation/widgets/home_streak_section.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class HomePage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => const HomePage());

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userGoal = '';
  bool _isPremiumCached = false;
  StreamSubscription<void>? _realtimeSubscription;
  Timer? _statusTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUserGoal();
    context.read<HomeBloc>().add(HomeFetchRequested());
    _setupRealtimeSubscriptions();
    _startStatusTimer();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
    _realtimeSubscription = sl<HomeRepository>().homeRealtimeChanges
        .listen((_) {
          if (_debounceTimer?.isActive ?? false) {
            _debounceTimer!.cancel();
          }
          _debounceTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) {
              context.read<HomeBloc>().add(
                HomeFetchRequested(isSilent: true),
              );
              _loadUserGoal();
            }
          });
        });
  }

  Future<void> _loadUserGoal() async {
    final activeGroup = await UserLocalDataSource.getUserGroupTitle();
    final goal = await UserLocalDataSource.getUserGoal();
    final subStatus = await UserLocalDataSource.getSubscriptionStatus();
    if (mounted) {
      setState(() {
        _userGoal = (activeGroup != null && activeGroup.isNotEmpty)
            ? activeGroup
            : _formatGoal(goal);
        _isPremiumCached = subStatus == 'active' || subStatus == 'trial';
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
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        int unreadCount = 0;
        bool isPremium = _isPremiumCached; // Use cached value by default (for offline/loading)
        if (state is HomeSuccess) {
          unreadCount = state.homeModel.stats.unreadNotificationsCount;
          isPremium = state.homeModel.isPremium; // Override with fresh DB data if available
        }

        return Scaffold(
          appBar: HomeAppBar(
            unreadNotificationsCount: unreadCount,
            isPremium: isPremium,
          ),
          body: GradientBackground(child: _buildBodyContent(context, state)),
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: Loader());
    }

    if (state is HomeFailure) {
      return ErrorStateWidget(
        errorType: state.errorType,
        message: state.message,
        onRetry: () {
          context.read<HomeBloc>().add(HomeFetchRequested(isSilent: true));
        },
      );
    }

    if (state is HomeSuccess) {
      final data = state.homeModel;
      return RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(HomeFetchRequested());
          await _loadUserGoal();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target & Active Exam Block
              HomeActiveExamSection(
                exam: data.activeExam,
                hasSubmitted: data.hasSubmittedActiveExam,
                userGoal: _userGoal,
              ),
              if (data.activeExam != null &&
                  !DateTime.now().isAfter(data.activeExam!.startTime
                      .add(Duration(minutes: data.activeExam!.durationMinutes))))
                const SizedBox(height: 20),

              // Daily Streak Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HomeStreakSection(
                  streakCount: data.stats.streakCount,
                  highestStreak: data.stats.highestStreak,
                  weeklyActiveDays: data.stats.weeklyActiveDays,
                ),
              ),
              const SizedBox(height: 20),

              // Latest Performance Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HomeLatestPerformanceSection(
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
              const HomeQuickActionsSection(),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}