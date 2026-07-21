import 'package:flutter/material.dart' hide BackButton;
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
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
      final results = await BattleRepo.getExamLeaderboardData(widget.examId);

      if (mounted) {
        setState(() {
          _examDetails = results[0] as Map<String, dynamic>?;
          _submissions = List<Map<String, dynamic>>.from(results[1] as List);
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
                  final correct = item['correct_count'] as int? ?? 0;
                  final wrong = item['wrong_count'] as int? ?? 0;
                  final isMe = item['user_id'] == _userId;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.divider.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank
                        SizedBox(
                          width: 32,
                          child: Text(
                            '#$rank',
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        // Avatar
                        _buildAvatar(avatarUrl, name, 36, isMe),
                        const SizedBox(width: 12),
                        // Name & Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppFonts.body(
                                  fontSize: 14,
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                                  color: isMe ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Correct: $correct · Wrong: $wrong',
                                style: AppFonts.body(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Score
                        Text(
                          '${score.round()}/100',
                          style: AppFonts.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
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

  Widget _buildAvatar(String avatarUrl, String name, double size, bool isMe) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isMe ? AppColors.primary : AppColors.divider.withValues(alpha: 0.5),
          width: isMe ? 2.0 : 1.0,
        ),
      ),
      child: avatarUrl.isNotEmpty
          ? CustomCachedImage(
              imageUrl: avatarUrl,
              width: size,
              height: size,
              borderRadius: size / 2,
            )
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: (isMe ? AppColors.primary : AppColors.grey).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: AppFonts.body(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.bold,
                    color: isMe ? AppColors.primary : AppColors.textLight,
                  ),
                ),
              ),
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
