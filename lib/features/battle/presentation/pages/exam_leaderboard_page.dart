import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';
import 'package:target_ace/core/components/leaderboard_row.dart';
import 'package:target_ace/core/components/back_button.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/podium_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';

class ExamLeaderboardPage extends StatefulWidget {
  final String examId;
  final String examTitle;

  static Route route({required String examId, required String examTitle}) {
    return MaterialPageRoute(
      builder: (_) => ExamLeaderboardPage(
        examId: examId,
        examTitle: examTitle,
      ),
    );
  }

  const ExamLeaderboardPage({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<ExamLeaderboardPage> createState() => _ExamLeaderboardPageState();
}

class _ExamLeaderboardPageState extends State<ExamLeaderboardPage> {

  bool _isLoading = true;
  String _userId = '';
  Map<String, dynamic>? _examDetails;
  List<Map<String, dynamic>> _submissions = [];
  Map<String, dynamic>? _currentUserRecord;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _userId = await AppPreferences.getUserId();
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await BattleRepo.getExamLeaderboardData(widget.examId, userId: _userId);

      if (mounted) {
        setState(() {
          _examDetails = results[0] as Map<String, dynamic>?;
          _submissions = List<Map<String, dynamic>>.from(results[1] as List);
          _currentUserRecord = results[2] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching exam leaderboard: $e');
    }
  }

  Widget? _buildMyRankPinnedBanner() {
    if (_isLoading || _currentUserRecord == null) return null;
    
    final isInsideTop50 = _submissions.any((s) => s['user_id'] == _userId);
    if (isInsideTop50) return null;

    final rank = _currentUserRecord!['rank'] as int? ?? 0;
    final profile = _currentUserRecord!['profiles'] as Map<String, dynamic>?;
    final name = profile != null ? (profile['name'] as String? ?? 'Student') : 'Student';
    final avatarUrl = profile != null ? (profile['avatar_url'] as String? ?? '') : '';
    final score = (_currentUserRecord!['score'] as num?)?.toDouble() ?? 0.0;
    final timeTaken = _currentUserRecord!['time_taken_seconds'] as int? ?? 0;

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
            'Time Taken: ${timeTaken ~/ 60}m ${timeTaken % 60}s',
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
            icon: HugeIcons.strokeRoundedStarAward02,
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
                      _examDetails!['title'] as String? ?? widget.examTitle,
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
                          label: '${_examDetails!['total_questions'] ?? 0} Questions',
                        ),
                        _buildDetailChip(
                          icon: HugeIcons.strokeRoundedClock01,
                          label: '${_examDetails!['duration_minutes'] ?? 0} Mins',
                        ),
                        _buildDetailChip(
                          icon: HugeIcons.strokeRoundedAward01,
                          label: '+${(_examDetails!['per_question_mark'] as num?)?.toDouble() ?? 1.0} / -${(_examDetails!['negative_mark'] as num?)?.toDouble() ?? 0.25}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Beautiful Podium for Top 3
        if (podiumItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: _buildPodium(podiumItems),
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
                  final profile = item['profiles'] as Map<String, dynamic>?;
                  final name = profile != null ? (profile['name'] as String? ?? 'Student') : 'Student';
                  final avatarUrl = profile != null ? (profile['avatar_url'] as String? ?? '') : '';
                  final score = (item['score'] as num?)?.toDouble() ?? 0.0;
                  final timeTaken = item['time_taken_seconds'] as int? ?? 0;
                  final isMe = item['user_id'] == _userId;

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
                      'Time Taken: ${timeTaken ~/ 60}m ${timeTaken % 60}s',
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

  Widget _buildPodium(List<Map<String, dynamic>> topList) {
    final items = List<Map<String, dynamic>?>.filled(3, null);
    for (int i = 0; i < topList.length && i < 3; i++) {
      items[i] = topList[i];
    }

    final podiumUsers = List<PodiumUser?>.generate(3, (index) {
      final item = items[index];
      if (item == null) return null;

      final profile = item['profiles'] as Map<String, dynamic>?;
      return PodiumUser(
        name: profile != null ? (profile['name'] as String? ?? 'Student') : 'Student',
        avatarUrl: profile != null ? (profile['avatar_url'] as String? ?? '') : '',
        score: (item['score'] as num?)?.toDouble() ?? 0.0,
        isMe: item['user_id'] == _userId,
      );
    });

    return PodiumWidget(
      users: podiumUsers,
      scoreSuffix: '/100',
    );
  }
}
