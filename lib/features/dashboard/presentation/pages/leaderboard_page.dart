import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/components/leaderboard_row.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/dashboard/presentation/widgets/podium_widget.dart';
import 'package:target_ace/core/shared/widgets/gradient_background.dart';
import 'package:target_ace/core/shared/widgets/loader.dart';
import 'package:target_ace/core/shared/widgets/empty_state_widget.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = true;
  String _userId = '';
  String _groupId = '';
  String _groupTitle = '';

  List<Map<String, dynamic>> _groupList = [];

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFetch();
  }

  Future<void> _loadPreferencesAndFetch() async {
    setState(() => _isLoading = true);
    _userId = await AppPreferences.getUserId();
    _groupId = await AppPreferences.getActiveGroupId();
    _groupTitle = await AppPreferences.getActiveGroupTitle();

    if (_groupId.isEmpty) {
      _groupId = await AppPreferences.getUserGroup();
    }
    if (_groupId.isEmpty) {
      _groupId = await AppPreferences.getUserGoal();
    }
    if (_groupTitle.isEmpty) {
      _groupTitle = 'Your Group';
    }

    await _fetchLeaderboards();
  }

  Future<void> _fetchLeaderboards() async {
    try {
      final groupData = await _client
          .from('group_leaderboard')
          .select()
          .eq('group_id', _groupId)
          .order('total_score', ascending: false)
          .limit(50);

      if (mounted) {
        setState(() {
          _groupList = List<Map<String, dynamic>>.from(groupData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching leaderboards: $e');
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
          child: _isLoading
              ? const Center(child: Loader())
              : RefreshIndicator(
                  onRefresh: _fetchLeaderboards,
                  backgroundColor: AppColors.card,
                  color: AppColors.primary,
                  child: _groupList.isEmpty
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
          title: 'Standings are Empty',
          message: 'Be the first to join a live battle and rank in $_groupTitle!',
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Unpack top 3 for the podium
    final podiumItems = _groupList.take(3).toList();
    final remainingItems = _groupList.skip(3).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Beautiful 3D Podium
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: _buildPodium(podiumItems),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),

        // List for Rank 4+
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = remainingItems[index];
                final rank = index + 4; // Start from Rank 4
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
          child: SizedBox(height: 80), // Bottom padding for navigation bar
        ),
      ],
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
      return PodiumUser(
        name: item['name'] as String? ?? 'Student',
        avatarUrl: item['avatar_url'] as String? ?? '',
        score: (item['total_score'] as num?)?.toDouble() ?? 0.0,
        isMe: item['user_id'] == _userId,
      );
    });

    return PodiumWidget(
      users: podiumUsers,
      scoreSuffix: ' pts',
    );
  }
}
