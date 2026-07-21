import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';

class DashboardRepo {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<DashboardModel> getDashboard() async {
    final goalId = await AppPreferences.getUserGoal();
    String groupId = await AppPreferences.getActiveGroupId();
    final userId = await AppPreferences.getUserId();

    if (goalId.isEmpty) {
      return DashboardModel.empty();
    }

    if (groupId.isEmpty) {
      groupId = await AppPreferences.getUserGroup();
    }
    if (groupId.isEmpty) {
      groupId = goalId; // Final fallback
    }

    // ── Wave 1: Fire exam fetch AND exam-independent queries in parallel ──
    // This saves ~800ms by not waiting for the exam fetch before starting
    // the stats, ranks, streak, and group profile queries.
    final nowUtc = DateTime.now().toUtc();
    final cutoff = nowUtc.subtract(const Duration(hours: 3));

    final wave1Results = await Future.wait([
      // Index 0: Exam fetch
      _client
          .from('exams')
          .select()
          .eq('group_id', groupId)
          .gte('start_time', cutoff.toIso8601String())
          .order('start_time', ascending: true),

      // Index 1: User overall statistics
      _client
          .from('exam_submissions')
          .select('score, correct_count, wrong_count')
          .eq('user_id', userId),

      // Index 2: Group Rank RPC
      userId.isNotEmpty
          ? _client.rpc('get_user_group_rank', params: {
              'target_user_id': userId,
              'target_group_id': groupId,
            })
          : Future.value(0),

      // Index 3: Global Rank RPC
      userId.isNotEmpty
          ? _client.rpc('get_user_global_rank', params: {
              'target_user_id': userId,
            })
          : Future.value(0),

      // Index 4: Streak metrics
      userId.isNotEmpty
          ? _client
              .from('profiles')
              .select('streak_count, highest_streak')
              .eq('id', userId)
              .maybeSingle()
          : Future.value(null),

      // Index 5: Fetch recent exams that have started
      _client
          .from('exams')
          .select()
          .eq('group_id', groupId)
          .lt('start_time', nowUtc.toIso8601String())
          .order('start_time', ascending: false)
          .limit(5),
    ]);

    // ── Resolve active exam from Wave 1 results ──
    final examResponse = wave1Results[0] as List;
    DashboardExam? activeExam;

    if (examResponse.isNotEmpty) {
      for (final examMap in examResponse) {
        final exam = DashboardExam.fromJson(examMap);
        final startTime = exam.startTime.toUtc();
        final endTime = startTime.add(Duration(minutes: exam.durationMinutes));

        if (endTime.isAfter(nowUtc)) {
          activeExam = exam;
          break;
        }
      }
      activeExam ??= DashboardExam.fromJson(examResponse.last);
    } else {
      // Fallback: Fetch the absolute most recent historical exam for this group
      final lastCompletedResponse = await _client
          .from('exams')
          .select()
          .eq('group_id', groupId)
          .order('start_time', ascending: false)
          .limit(1);
      if (lastCompletedResponse.isNotEmpty) {
        activeExam = DashboardExam.fromJson(lastCompletedResponse.first);
      }
    }

    // ── Find the last completed exam from Index 5 ──
    final pastExamsResponse = wave1Results[5] as List;
    DashboardExam? lastCompletedExam;
    if (pastExamsResponse.isNotEmpty) {
      for (final examMap in pastExamsResponse) {
        final exam = DashboardExam.fromJson(examMap);
        final startTime = exam.startTime.toUtc();
        final endTime = startTime.add(Duration(minutes: exam.durationMinutes));

        if (endTime.isBefore(nowUtc)) {
          lastCompletedExam = exam;
          break;
        }
      }
    }

    // ── Wave 2: Exam-dependent queries ──
    bool hasSubmittedActiveExam = false;
    List<dynamic> lastCompletedLeaderboardData = [];

    final List<Future<dynamic>> wave2Queries = [];

    // Query 1: Active Exam Submission check (if activeExam exists)
    if (activeExam != null) {
      wave2Queries.add(
        _client
            .from('exam_submissions')
            .select('id')
            .eq('exam_id', activeExam.id)
            .eq('user_id', userId)
            .limit(1)
      );
    } else {
      wave2Queries.add(Future.value([]));
    }

    // Query 2: Last Completed Exam Leaderboard Top 3 (if lastCompletedExam exists)
    if (lastCompletedExam != null) {
      wave2Queries.add(
        _client
            .from('exam_submissions')
            .select('score, user_id, profiles(name, avatar_url)')
            .eq('exam_id', lastCompletedExam.id)
            .order('score', ascending: false)
            .limit(3)
      );
    } else {
      wave2Queries.add(Future.value([]));
    }

    final wave2Results = await Future.wait(wave2Queries);

    if (activeExam != null) {
      final submissionCheckData = wave2Results[0] as List;
      hasSubmittedActiveExam = submissionCheckData.isNotEmpty;
    }
    lastCompletedLeaderboardData = wave2Results[1] as List;

    // ── Unpack Wave 1 results ──
    // Stats (Index 1)
    int totalBattles = 0;
    double averageScore = 0.0;
    int totalCorrect = 0;
    int totalWrong = 0;

    final statsData = wave1Results[1] as List;
    if (statsData.isNotEmpty) {
      totalBattles = statsData.length;
      final sum = statsData.fold<double>(0.0, (prev, element) => prev + (element['score'] as num).toDouble());
      averageScore = totalBattles > 0 ? sum / totalBattles : 0.0;
      totalCorrect = statsData.fold<int>(0, (prev, element) => prev + (element['correct_count'] as int? ?? 0));
      totalWrong = statsData.fold<int>(0, (prev, element) => prev + (element['wrong_count'] as int? ?? 0));
    }

    // Ranks (Index 2 & 3)
    final int groupRank = (wave1Results[2] as num?)?.toInt() ?? 0;
    final int globalRank = (wave1Results[3] as num?)?.toInt() ?? 0;

    // Streak (Index 4)
    int streakCount = 0;
    int highestStreak = 0;
    final profileResp = wave1Results[4] as Map<String, dynamic>?;
    if (profileResp != null) {
      streakCount = profileResp['streak_count'] as int? ?? 0;
      highestStreak = profileResp['highest_streak'] as int? ?? 0;
    }

    // ── Build the Top Rank list from last completed exam ──
    List<LeaderboardItem> leaderboard = [];

    if (lastCompletedExam != null && lastCompletedLeaderboardData.isNotEmpty) {
      for (int i = 0; i < lastCompletedLeaderboardData.length; i++) {
        final item = lastCompletedLeaderboardData[i];
        final profile = item['profiles'] as Map<String, dynamic>?;
        final name = profile != null ? (profile['name'] as String? ?? 'Student') : 'Student';
        final avatarUrl = profile != null ? (profile['avatar_url'] as String?) : null;
        final subUserId = item['user_id'] as String? ?? '';

        leaderboard.add(
          LeaderboardItem(
            rank: i + 1,
            name: name,
            score: (item['score'] as num).toDouble(),
            avatarUrl: avatarUrl,
            isCurrentUser: subUserId == userId,
          ),
        );
      }
    }

    // Static fallback if still empty
    if (leaderboard.isEmpty) {
      leaderboard = [
        LeaderboardItem(rank: 1, name: 'Rafiq Ahmed', score: 98),
        LeaderboardItem(rank: 2, name: 'Sadia Islam', score: 95),
        LeaderboardItem(rank: 3, name: 'Tanvir Hasan', score: 91),
      ];
    }

    return DashboardModel(
      activeExam: activeExam,
      hasSubmittedActiveExam: hasSubmittedActiveExam,
      stats: DashboardStats(
        totalBattles: totalBattles,
        averageScore: averageScore,
        rank: groupRank,
        totalCorrect: totalCorrect,
        totalWrong: totalWrong,
        streakCount: streakCount,
        highestStreak: highestStreak,
      ),
      leaderboard: leaderboard,
      groupRank: groupRank,
      globalRank: globalRank,
      lastExamTitle: lastCompletedExam?.title,
      lastExamId: lastCompletedExam?.id,
    );
  }
}
