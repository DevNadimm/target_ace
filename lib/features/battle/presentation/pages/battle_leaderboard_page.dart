import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/services/service_locator.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_leaderboard_data.dart';
import 'package:target_ace/core/components/leaderboard_row.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/podium_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

class BattleLeaderboardPage extends StatefulWidget {
  final String examId;
  final String examTitle;

  static Route route({required String examId, required String examTitle}) {
    return MaterialPageRoute(
      builder: (_) => BattleLeaderboardPage(
        examId: examId,
        examTitle: examTitle,
      ),
    );
  }

  const BattleLeaderboardPage({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<BattleLeaderboardPage> createState() => _BattleLeaderboardPageState();
}

class _BattleLeaderboardPageState extends State<BattleLeaderboardPage> {
  bool _isLoading = true;
  String _userId = '';
  BattleEntity? _examDetails;
  List<LeaderboardEntryEntity> _submissions = [];
  LeaderboardEntryEntity? _currentUserRecord;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _userId = await UserLocalDataSource.getUserId();
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final getBattleLeaderboardData = sl<GetBattleLeaderboardData>();
      final eitherResults = await getBattleLeaderboardData(
        GetBattleLeaderboardDataParams(examId: widget.examId, userId: _userId),
      );

      await eitherResults.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (results) async {
          if (mounted) {
            setState(() {
              _examDetails = results.exam;
              _submissions = results.topSubmissions;
              _currentUserRecord = results.currentUserRecord;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching battle leaderboard: $e');
    }
  }

  Widget? _buildMyRankPinnedBanner() {
    if (_isLoading || _currentUserRecord == null) return null;
    
    final isInsideTop50 = _submissions.any((s) => s.isCurrentUser);
    if (isInsideTop50) return null;

    final rank = _currentUserRecord!.rank;
    final name = _currentUserRecord!.name;
    final avatarUrl = _currentUserRecord!.avatarUrl;
    final score = _currentUserRecord!.score;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: LeaderboardRow(
          rank: rank,
          name: name,
          avatarUrl: avatarUrl,
          isMe: true,
          avatarSize: 38,
          rankWidth: 38,
          padding: EdgeInsets.zero,
          subtitle: Text(
            'Your Battle Rank',
            style: AppFonts.body(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          trailing: Text(
            '${score.round()}/100',
            style: AppFonts.body(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Battle Standings"),
        leading: const BackButton(),
        automaticallyImplyLeading: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(child: Loader())
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  backgroundColor: AppColors.card,
                  color: AppColors.primary,
                  child: _submissions.isEmpty
                      ? _buildEmptyState()
                      : _buildContent(),
                ),
        ),
      ),
      bottomNavigationBar: _buildMyRankPinnedBanner(),
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
          title: 'No Standings Available',
          message: 'Nobody has participated in this battle yet!',
        ),
      ),
    );
  }

  Widget _buildContent() {
    final podiumItems = _submissions.take(3).toList();
    final remainingItems = _submissions.skip(3).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Exam Details Card
        if (_examDetails != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _examDetails!.title,
                      style: AppFonts.heading(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailChip(
                          icon: HugeIcons.strokeRoundedBookOpen01,
                          label: '${_examDetails!.totalQuestions} Questions',
                        ),
                        _buildDetailChip(
                          icon: HugeIcons.strokeRoundedClock01,
                          label: '${_examDetails!.durationMinutes} Mins',
                        ),
                        _buildDetailChip(
                          icon: HugeIcons.strokeRoundedChampion,
                          label: '+${_examDetails!.perQuestionMark} / -${_examDetails!.negativeMark}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Beautiful PodiumWidget for Top 3
        if (podiumItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: _buildPodiumWidget(podiumItems),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),

        // List for remaining participants
        if (remainingItems.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = remainingItems[index];
                  final rank = index + 4;
                  final name = item.name;
                  final avatarUrl = item.avatarUrl;
                  final score = item.score;
                  final isMe = item.isCurrentUser;

                  return LeaderboardRow(
                    rank: rank,
                    name: name,
                    avatarUrl: avatarUrl,
                    isMe: isMe,
                    avatarSize: 36,
                    rankWidth: 32,
                    hasBottomBorder: true,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    subtitle: Text(
                      isMe ? 'Your Battle Rank' : 'Battle Contestant',
                      style: AppFonts.body(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                    trailing: Text(
                      '${score.round()}/100',
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  );
                },
                childCount: remainingItems.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailChip({required dynamic icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.body(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumWidget(List<LeaderboardEntryEntity> topList) {
    final items = List<LeaderboardEntryEntity?>.filled(3, null);
    for (int i = 0; i < topList.length && i < 3; i++) {
      items[i] = topList[i];
    }

    final podiumUsers = List<PodiumWidgetUser?>.generate(3, (index) {
      final item = items[index];
      if (item == null) return null;

      return PodiumWidgetUser(
        name: item.name,
        avatarUrl: item.avatarUrl,
        score: item.score,
        isMe: item.isCurrentUser,
      );
    });

    return PodiumWidget(
      users: podiumUsers,
      scoreSuffix: '/100',
    );
  }
}
