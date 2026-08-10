import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/leaderboard_row.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/shared/widgets/error_state_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/features/home/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:target_ace/features/home/presentation/widgets/home_podium_section.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LeaderboardCubit>(),
      child: const _LeaderboardPageView(),
    );
  }
}

class _LeaderboardPageView extends StatefulWidget {
  const _LeaderboardPageView();

  @override
  State<_LeaderboardPageView> createState() => _LeaderboardPageViewState();
}

class _LeaderboardPageViewState extends State<_LeaderboardPageView> {
  String _userId = '';
  String _groupId = '';
  String _groupTitle = '';

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFetch();
  }

  Future<void> _loadPreferencesAndFetch() async {
    _userId = await UserLocalDataSource.getUserId();
    _groupId = await UserLocalDataSource.getUserGroupId();
    _groupTitle = await UserLocalDataSource.getUserGroupTitle() ?? '';

    if (_groupId.isEmpty) {
      _groupId = await UserLocalDataSource.getUserGroupId();
    }
    if (_groupId.isEmpty) {
      _groupId = await UserLocalDataSource.getUserGoal();
    }
    if (_groupTitle.isEmpty) {
      _groupTitle = 'Your Group';
    }

    if (mounted) {
      context.read<LeaderboardCubit>().fetchLeaderboard(_groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading || state is LeaderboardInitial) {
                return const Center(child: Loader());
              }

              if (state is LeaderboardFailure) {
                return ErrorStateWidget(
                  message: state.message,
                  errorType: state.errorType,
                  onRetry: () => context.read<LeaderboardCubit>().fetchLeaderboard(_groupId, isSilent: true),
                );
              }

              if (state is LeaderboardSuccess) {
                final groupList = state.leaderboard;
                return RefreshIndicator(
                  onRefresh: () async => context.read<LeaderboardCubit>().fetchLeaderboard(_groupId),
                  backgroundColor: AppColors.card,
                  color: AppColors.primary,
                  child: groupList.isEmpty
                      ? _buildEmptyState()
                      : _buildContent(groupList),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 120.0),
        child: EmptyStateWidget(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedChampion,
            color: AppColors.primary,
            size: 64,
          ),
          title: 'Standings are Empty',
          message: 'Be the first to join a live battle and rank in $_groupTitle!',
        ),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> groupList) {
    final podiumItems = groupList.take(3).toList();
    final remainingItems = groupList.skip(3).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: _buildHomePodiumSection(podiumItems),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = remainingItems[index];
                final rank = index + 4;
                final name = item['name'] as String? ?? 'Student';
                final score = (item['total_score'] as num?)?.toDouble() ?? 0.0;
                final examsTaken = item['exams_taken'] as int? ?? 0;
                final avatarUrl = item['avatar_url'] as String? ?? '';
                final isMe = item['user_id'] == _userId;

                final handle = '@${name.replaceAll(' ', '').toLowerCase()}';
                final avgScore = examsTaken > 0 ? (score / examsTaken) : 0.0;

                return LeaderboardRow(
                  rank: rank,
                  name: name,
                  avatarUrl: avatarUrl,
                  isMe: isMe,
                  avatarSize: 36,
                  rankWidth: 28,
                  subtitle: Text(
                    handle,
                    style: AppFonts.body(
                      fontSize: 11.5,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.accentYellow,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${score.round()}',
                            style: AppFonts.body(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${avgScore.toStringAsFixed(1)}%',
                        style: AppFonts.body(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.labelGreen,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: remainingItems.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildHomePodiumSection(List<Map<String, dynamic>> topList) {
    final items = List<Map<String, dynamic>?>.filled(3, null);
    for (int i = 0; i < topList.length && i < 3; i++) {
      items[i] = topList[i];
    }

    final podiumUsers = List<HomePodiumUser?>.generate(3, (index) {
      final item = items[index];
      if (item == null) return null;
      return HomePodiumUser(
        name: item['name'] as String? ?? 'Student',
        avatarUrl: item['avatar_url'] as String? ?? '',
        score: (item['total_score'] as num?)?.toDouble() ?? 0.0,
        isMe: item['user_id'] == _userId,
      );
    });

    return HomePodiumSection(
      users: podiumUsers,
      scoreSuffix: ' pts',
    );
  }
}