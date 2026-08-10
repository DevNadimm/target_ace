import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/spring_button.dart';
import 'package:target_ace/features/home/presentation/widgets/home_podium_section.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/battle/presentation/pages/battle_review_page.dart';

class BattleScoreboardView extends StatelessWidget {
  final String examId;
  final String examTitle;
  final double score;
  final int examRank;
  final int groupRank;
  final int globalRank;
  final List<LeaderboardEntryEntity> leaderboard;
  final List<Map<String, dynamic>> userAnswersList;
  final VoidCallback onExit;

  const BattleScoreboardView({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.score,
    required this.examRank,
    required this.groupRank,
    required this.globalRank,
    required this.leaderboard,
    required this.userAnswersList,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final podiumItems = leaderboard.take(3).toList();
    final remainingItems = leaderboard.skip(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14), // Deep dark base
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Glassmorphic Player Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: _buildTriumphPlayerCard(),
                        ),
                      ),
                      
                      // Victory Podium
                      if (podiumItems.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                            child: _buildPodiumSection(podiumItems),
                          ),
                        ),
                      
                      // Layered Leaderboard List
                      if (remainingItems.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = remainingItems[index];
                                return _buildLayeredLeaderboardRow(item);
                              },
                              childCount: remainingItems.length,
                            ),
                          ),
                        ),
                        
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 120), // Padding for floating CTA
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedAiNetwork, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'MATCH COMPLETE',
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriumphPlayerCard() {
    int correct = userAnswersList.where((ans) => ans['is_correct'] == true).length;
    int wrong = userAnswersList.where((ans) => ans['is_correct'] == false && ans['selected_option'] != null).length;
    int skipped = userAnswersList.length - correct - wrong;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Top Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR SCORE',
                        style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${score.round()}',
                            style: AppFonts.heading(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PTS',
                            style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Glowing Ranks
                  Row(
                    children: [
                      _buildNeonRankBadge('EXAM', examRank, AppColors.primary),
                      const SizedBox(width: 8),
                      _buildNeonRankBadge('GROUP', groupRank, AppColors.labelGreen),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Dynamic Accuracy Track
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCURACY BREAKDOWN',
                    style: AppFonts.body(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: [
                          if (correct > 0) Expanded(flex: correct, child: Container(color: AppColors.labelGreen)),
                          if (wrong > 0) Expanded(flex: wrong, child: Container(color: AppColors.error)),
                          if (skipped > 0) Expanded(flex: skipped, child: Container(color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAccuracyLegend('Correct', correct, AppColors.labelGreen),
                      _buildAccuracyLegend('Wrong', wrong, AppColors.error),
                      _buildAccuracyLegend('Skipped', skipped, AppColors.grey),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeonRankBadge(String label, int rank, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppFonts.body(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0),
          ),
          const SizedBox(height: 2),
          Text(
            '#$rank',
            style: AppFonts.heading(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $count',
          style: AppFonts.body(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildPodiumSection(List<LeaderboardEntryEntity> topList) {
    final items = List<LeaderboardEntryEntity?>.filled(3, null);
    for (int i = 0; i < topList.length && i < 3; i++) {
      items[i] = topList[i];
    }

    final podiumUsers = List<HomePodiumUser?>.generate(3, (index) {
      final item = items[index];
      if (item == null) return null;
      return HomePodiumUser(
        name: item.name,
        avatarUrl: item.avatarUrl,
        score: item.score,
        isMe: item.isCurrentUser,
      );
    });

    return HomePodiumSection(
      users: podiumUsers,
      scoreSuffix: ' pts',
    );
  }

  Widget _buildLayeredLeaderboardRow(LeaderboardEntryEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isCurrentUser ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isCurrentUser ? AppColors.primary : AppColors.divider.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${item.rank}',
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: item.isCurrentUser ? FontWeight.w900 : FontWeight.w600,
                color: item.isCurrentUser ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.background,
            backgroundImage: item.avatarUrl.isNotEmpty ? NetworkImage(item.avatarUrl) : null,
            child: item.avatarUrl.isEmpty
                ? Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : 'U', style: AppFonts.body(color: AppColors.textSecondary))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: item.isCurrentUser ? FontWeight.bold : FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "YOU",
                          style: AppFonts.body(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '@${item.name.replaceAll(' ', '').toLowerCase()}',
                  style: AppFonts.body(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${item.score.round()} PTS',
            style: AppFonts.heading(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: item.isCurrentUser ? AppColors.primary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D0F14).withValues(alpha: 0.1),
                const Color(0xFF0D0F14).withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: SpringButton(
                  backgroundColor: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  height: 56.0,
                  onPressed: () {
                    Navigator.push(context, BattleReviewPage.route(
                      examId: examId,
                      userAnswers: userAnswersList,
                    ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const HugeIcon(icon: HugeIcons.strokeRoundedCrown, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'REVIEW ANSWERS',
                        style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRO',
                          style: AppFonts.body(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SpringButton.outlined(
                  borderColor: Colors.white.withValues(alpha: 0.2),
                  onPressed: onExit,
                  height: 52.0,
                  child: Text(
                    'BACK TO HOME',
                    style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}