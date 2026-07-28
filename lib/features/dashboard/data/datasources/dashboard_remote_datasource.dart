import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard({
    required String goalId,
    required String groupId,
    required String userId,
  });
  Future<List<Map<String, dynamic>>> getGroupLeaderboard(String groupId);
  Stream<void> get dashboardRealtimeChanges;
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabaseClient;

  DashboardRemoteDataSourceImpl(this.supabaseClient);

  @override
  Stream<void> get dashboardRealtimeChanges {
    late StreamController<void> controller;
    RealtimeChannel? examsChannel;
    RealtimeChannel? submissionsChannel;

    controller = StreamController<void>.broadcast(
      onListen: () {
        examsChannel = supabaseClient
            .channel('public-exams-dashboard')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'exams',
              callback: (payload) {
                if (!controller.isClosed) {
                  controller.add(null);
                }
              },
            );
        examsChannel!.subscribe();

        submissionsChannel = supabaseClient
            .channel('public-submissions-dashboard')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'exam_submissions',
              callback: (payload) {
                if (!controller.isClosed) {
                  controller.add(null);
                }
              },
            );
        submissionsChannel!.subscribe();
      },
      onCancel: () {
        if (examsChannel != null) {
          supabaseClient.removeChannel(examsChannel!);
        }
        if (submissionsChannel != null) {
          supabaseClient.removeChannel(submissionsChannel!);
        }
      },
    );

    return controller.stream;
  }

  @override
  Future<List<Map<String, dynamic>>> getGroupLeaderboard(String groupId) async {
    try {
      final response = await supabaseClient
          .from('group_leaderboard')
          .select()
          .eq('group_id', groupId)
          .order('total_score', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<DashboardModel> getDashboard({
    required String goalId,
    required String groupId,
    required String userId,
  }) async {
    try {
      if (goalId.isEmpty) {
        return DashboardModel.empty();
      }

      final targetGroupId = groupId.isEmpty ? goalId : groupId;

      // ── Single Atomic RPC Call (1 HTTP RTT) ──
      try {
        final resp = await supabaseClient.rpc('get_user_dashboard_summary', params: {
          'target_user_id': userId,
          'target_group_id': targetGroupId,
        });

        if (resp != null && resp is Map<String, dynamic>) {
          final activeExamMap = resp['active_exam'] as Map<String, dynamic>?;
          final activeExam = activeExamMap != null ? DashboardExamModel.fromJson(activeExamMap) : null;
          final hasSubmittedActive = resp['has_submitted_active'] as bool? ?? false;
          final isPremium = resp['is_premium'] as bool? ?? false;
          final planName = resp['plan_name'] as String? ?? 'Free Member';
          final subStatus = resp['subscription_status'] as String? ?? 'none';
          final expiryStr = resp['premium_expires_at'] as String?;

          await AppPreferences.setSubscriptionPlanName(planName);
          await AppPreferences.setSubscriptionStatus(subStatus);
          if (expiryStr != null) {
            await AppPreferences.setSubscriptionExpiryDate(expiryStr);
          } else {
            await AppPreferences.setSubscriptionExpiryDate('');
          }

          final totalBattles = (resp['total_battles'] as num? ?? 0).toInt();
          final averageScore = (resp['average_score'] as num? ?? 0.0).toDouble();
          final totalCorrect = (resp['total_correct'] as num? ?? 0).toInt();
          final totalWrong = (resp['total_wrong'] as num? ?? 0).toInt();
          final groupRank = (resp['group_rank'] as num? ?? 0).toInt();
          final globalRank = (resp['global_rank'] as num? ?? 0).toInt();
          final streakCount = (resp['streak_count'] as num? ?? 0).toInt();
          final highestStreak = (resp['highest_streak'] as num? ?? 0).toInt();
          final weeklyActiveDaysList = (resp['weekly_active_days'] as List?)?.map((e) => e.toString()).toList() ?? [];
          final unreadNotificationsCount = (resp['unread_notifications_count'] as num? ?? 0).toInt();

          LatestPerformanceModel? latestPerformance;
          final latestPerfMap = resp['latest_performance'] as Map<String, dynamic>?;
          if (latestPerfMap != null) {
            final examTitle = latestPerfMap['exam_title'] as String? ?? 'Live Exam';
            final completedAtStr = latestPerfMap['completed_at'] as String?;
            final completedAt = completedAtStr != null ? DateTime.parse(completedAtStr).toLocal() : DateTime.now();
            final score = (latestPerfMap['score'] as num? ?? 0).round();
            final scoreOutOf = (latestPerfMap['score_out_of'] as num? ?? 100).toInt();
            final correctCount = (latestPerfMap['correct_count'] as num? ?? 0).toInt();
            final wrongCount = (latestPerfMap['wrong_count'] as num? ?? 0).toInt();
            final totalAttempted = correctCount + wrongCount;
            final accuracy = totalAttempted > 0 ? (correctCount / totalAttempted) : 0.0;
            final rank = (latestPerfMap['rank'] as num? ?? 1).toInt();
            final totalParticipants = (latestPerfMap['total_participants'] as num? ?? 1).toInt();
            final timeTakenSeconds = (latestPerfMap['time_taken_seconds'] as num? ?? 0).toInt();

            latestPerformance = LatestPerformanceModel(
              examTitle: examTitle,
              completedAt: completedAt,
              score: score,
              scoreOutOf: scoreOutOf,
              accuracy: accuracy,
              rank: rank > 0 ? rank : 1,
              totalParticipants: totalParticipants > 0 ? totalParticipants : 1,
              timeTaken: Duration(seconds: timeTakenSeconds),
            );
          }

          return DashboardModel(
            activeExam: activeExam,
            hasSubmittedActiveExam: hasSubmittedActive,
            stats: DashboardStatsModel(
              totalBattles: totalBattles,
              averageScore: averageScore,
              rank: groupRank,
              totalCorrect: totalCorrect,
              totalWrong: totalWrong,
              streakCount: streakCount,
              highestStreak: highestStreak,
              weeklyActiveDays: weeklyActiveDaysList,
              unreadNotificationsCount: unreadNotificationsCount,
            ),
            leaderboard: [],
            groupRank: groupRank,
            globalRank: globalRank,
            latestPerformance: latestPerformance,
            isPremium: isPremium,
          );
        }
      } catch (_) {
        // Fallback to parallel wave queries if RPC is not run in Supabase yet
      }

      // ── Wave 1: Fire exam fetch AND exam-independent queries in parallel ──
      final nowUtc = DateTime.now().toUtc();

      final wave1Results = await Future.wait([
        // Index 0: Exam fetch
        supabaseClient
            .from('exams')
            .select()
            .eq('group_id', targetGroupId)
            .order('start_time', ascending: true),

        // Index 1: User overall statistics
        supabaseClient
            .from('exam_submissions')
            .select('score, correct_count, wrong_count')
            .eq('user_id', userId),

        // Index 2: Group Rank RPC
        userId.isNotEmpty
            ? supabaseClient.rpc('get_user_group_rank', params: {
                'target_user_id': userId,
                'target_group_id': targetGroupId,
              })
            : Future.value(0),

        // Index 3: Global Rank RPC
        userId.isNotEmpty
            ? supabaseClient.rpc('get_user_global_rank', params: {
                'target_user_id': userId,
              })
            : Future.value(0),

        // Index 4: Streak metrics & is_premium & premium_expires_at
        userId.isNotEmpty
            ? supabaseClient
                .from('profiles')
                .select('streak_count, highest_streak, weekly_active_days, is_premium, premium_expires_at, name, email, phone, gender, dob, institution, district, avatar_url, group_id')
                .eq('id', userId)
                .maybeSingle()
            : Future.value(null),

        // Index 5: Fetch recent exams that have started
        supabaseClient
            .from('exams')
            .select()
            .eq('group_id', targetGroupId)
            .lt('start_time', nowUtc.toIso8601String())
            .order('start_time', ascending: false)
            .limit(5),

        // Index 6: Unread notifications count query
        userId.isNotEmpty
            ? supabaseClient
                .from('notifications')
                .select('id')
                .eq('user_id', userId)
                .eq('is_read', false)
            : Future.value([]),

        // Index 7: Fetch latest subscription
        userId.isNotEmpty
            ? supabaseClient
                .from('subscriptions')
                .select('status, plan_id, plan_name')
                .eq('user_id', userId)
                .order('created_at', ascending: false)
                .limit(1)
            : Future.value([]),
      ]);

      // ── Resolve active exam from Wave 1 results ──
      final examResponse = wave1Results[0] as List;
      DashboardExamModel? activeExam;

      if (examResponse.isNotEmpty) {
        for (final examMap in examResponse) {
          final exam = DashboardExamModel.fromJson(examMap);
          final startTime = exam.startTime.toUtc();
          final endTime = startTime.add(Duration(minutes: exam.durationMinutes));

          if (endTime.isAfter(nowUtc)) {
            activeExam = exam;
            break;
          }
        }
        activeExam ??= DashboardExamModel.fromJson(examResponse.last);
      } else {
        final lastCompletedResponse = await supabaseClient
            .from('exams')
            .select()
            .eq('group_id', targetGroupId)
            .order('start_time', ascending: false)
            .limit(1);
        if (lastCompletedResponse.isNotEmpty) {
          activeExam = DashboardExamModel.fromJson(lastCompletedResponse.first);
        }
      }

      // ── Find the last completed exam from Index 5 ──
      final pastExamsResponse = wave1Results[5] as List;
      DashboardExamModel? lastCompletedExam;
      if (pastExamsResponse.isNotEmpty) {
        for (final examMap in pastExamsResponse) {
          final exam = DashboardExamModel.fromJson(examMap);
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

      if (activeExam != null) {
        wave2Queries.add(
          supabaseClient
              .from('exam_submissions')
              .select('id')
              .eq('exam_id', activeExam.id)
              .eq('user_id', userId)
              .limit(1)
        );
      } else {
        wave2Queries.add(Future.value([]));
      }

      if (lastCompletedExam != null) {
        wave2Queries.add(
          supabaseClient
              .from('leaderboards')
              .select('score, user_id, profiles(name, avatar_url)')
              .eq('exam_id', lastCompletedExam.id)
              .order('score', ascending: false)
              .order('time_taken_seconds', ascending: true)
              .limit(3)
        );
      } else {
        wave2Queries.add(Future.value([]));
      }

      if (userId.isNotEmpty) {
        wave2Queries.add(
          supabaseClient
              .from('exam_submissions')
              .select('*, exams(title)')
              .eq('user_id', userId)
              .order('completed_at', ascending: false)
              .limit(1)
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

      LatestPerformanceModel? latestPerformance;
      final latestSubData = wave2Results[2] as List;
      if (latestSubData.isNotEmpty) {
        final sub = latestSubData.first as Map<String, dynamic>;
        final examData = sub['exams'] as Map<String, dynamic>?;
        final examTitle = examData != null ? (examData['title'] as String? ?? 'Live Exam') : 'Live Exam';
        final score = (sub['score'] as num? ?? 0).round();
        final correctCount = (sub['correct_count'] as num? ?? 0).toInt();
        final wrongCount = (sub['wrong_count'] as num? ?? 0).toInt();
        final totalAttempted = correctCount + wrongCount;
        final accuracy = totalAttempted > 0 ? (correctCount / totalAttempted) : 0.0;
        final timeTakenSeconds = (sub['time_taken_seconds'] as num? ?? 0).toInt();
        final completedAtStr = sub['completed_at'] as String? ?? sub['submitted_at'] as String?;
        final completedAt = completedAtStr != null ? DateTime.parse(completedAtStr).toLocal() : DateTime.now();
        final examId = sub['exam_id'] as String? ?? '';

        int rank = 0;
        int totalParticipants = 0;

        if (examId.isNotEmpty) {
          try {
            final rankResults = await Future.wait<dynamic>([
              supabaseClient
                  .from('exam_submissions')
                  .select('id')
                  .eq('exam_id', examId),
              supabaseClient
                  .from('leaderboards')
                  .select('rank')
                  .eq('exam_id', examId)
                  .eq('user_id', userId)
                  .maybeSingle()
            ]);
            
            final participantsList = rankResults[0] as List;
            totalParticipants = participantsList.length;

            final rankResp = rankResults[1] as Map<String, dynamic>?;
            if (rankResp != null && rankResp['rank'] != null) {
              rank = (rankResp['rank'] as num).toInt();
            }

            if (rank == 0 && totalParticipants > 0) {
              final higherSubs = await supabaseClient
                  .from('exam_submissions')
                  .select('id')
                  .eq('exam_id', examId)
                  .gt('score', sub['score'] ?? 0);
              rank = (higherSubs as List).length + 1;
            }
          } catch (_) {}
        }

        latestPerformance = LatestPerformanceModel(
          examTitle: examTitle,
          completedAt: completedAt,
          score: score,
          scoreOutOf: 100,
          accuracy: accuracy,
          rank: rank > 0 ? rank : 1,
          totalParticipants: totalParticipants > 0 ? totalParticipants : 1,
          timeTaken: Duration(seconds: timeTakenSeconds),
        );
      }

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

      final int groupRank = (wave1Results[2] as num?)?.toInt() ?? 0;
      final int globalRank = (wave1Results[3] as num?)?.toInt() ?? 0;

      int streakCount = 0;
      int highestStreak = 0;
      bool isPremiumFallback = false;
      List<String> weeklyActiveDaysList = [];
      final profileResp = wave1Results[4] as Map<String, dynamic>?;
      if (profileResp != null) {
        streakCount = profileResp['streak_count'] as int? ?? 0;
        highestStreak = profileResp['highest_streak'] as int? ?? 0;
        isPremiumFallback = profileResp['is_premium'] as bool? ?? false;
        weeklyActiveDaysList = (profileResp['weekly_active_days'] as List?)?.map((e) => e.toString()).toList() ?? [];

        final expiryStr = profileResp['premium_expires_at'] as String?;
        if (profileResp['name'] != null) await AppPreferences.setUserName(profileResp['name'] as String);
        if (profileResp['phone'] != null) await AppPreferences.setUserPhone(profileResp['phone'] as String);
        if (profileResp['gender'] != null) await AppPreferences.setUserGender(profileResp['gender'] as String);
        if (profileResp['dob'] != null) await AppPreferences.setUserDob(profileResp['dob'] as String);
        if (profileResp['institution'] != null) await AppPreferences.setUserInstitution(profileResp['institution'] as String);
        if (profileResp['district'] != null) await AppPreferences.setUserDistrict(profileResp['district'] as String);
        if (profileResp['avatar_url'] != null) await AppPreferences.setUserAvatarUrl(profileResp['avatar_url'] as String);

        final subList = wave1Results[7] as List?;
        final latestSub = (subList != null && subList.isNotEmpty) ? subList.first as Map<String, dynamic> : null;

        final latestSubStatus = latestSub?['status'] as String?;
        final latestSubPlanId = latestSub?['plan_id'] as String?;
        final latestSubPlanName = latestSub?['plan_name'] as String?;

        String subStatus = 'none';
        final bool isExpired = expiryStr != null && DateTime.tryParse(expiryStr)?.isBefore(DateTime.now()) == true;

        if (isPremiumFallback && !isExpired) {
          final isTrial = latestSubPlanId == 'free_trial' || latestSubPlanName == 'Free Trial';
          subStatus = isTrial ? 'trial' : 'active';
        } else {
          if (latestSubStatus == 'pending') {
            subStatus = 'pending_verification';
          } else if (isExpired) {
            subStatus = 'expired';
          }
        }

        await AppPreferences.setSubscriptionStatus(subStatus);
        if (expiryStr != null) {
          await AppPreferences.setSubscriptionExpiryDate(expiryStr);
        } else {
          await AppPreferences.setSubscriptionExpiryDate('');
        }
      }

      int unreadNotificationsCount = 0;
      if (wave1Results.length > 6 && wave1Results[6] != null) {
        final unreadList = wave1Results[6] as List?;
        unreadNotificationsCount = unreadList?.length ?? 0;
      }

      List<LeaderboardItemModel> leaderboard = [];

      if (lastCompletedExam != null && lastCompletedLeaderboardData.isNotEmpty) {
        for (int i = 0; i < lastCompletedLeaderboardData.length; i++) {
          final item = lastCompletedLeaderboardData[i];
          final profile = item['profiles'] as Map<String, dynamic>?;
          final name = profile != null ? (profile['name'] as String? ?? 'Student') : 'Student';
          final avatarUrl = profile != null ? (profile['avatar_url'] as String?) : null;
          final subUserId = item['user_id'] as String? ?? '';

          leaderboard.add(
            LeaderboardItemModel(
              rank: i + 1,
              name: name,
              score: (item['score'] as num).toDouble(),
              avatarUrl: avatarUrl,
              isCurrentUser: subUserId == userId,
            ),
          );
        }
      }

      if (leaderboard.isEmpty) {
        leaderboard = [
          LeaderboardItemModel(rank: 1, name: 'Rafiq Ahmed', score: 98),
          LeaderboardItemModel(rank: 2, name: 'Sadia Islam', score: 95),
          LeaderboardItemModel(rank: 3, name: 'Tanvir Hasan', score: 91),
        ];
      }

      return DashboardModel(
        activeExam: activeExam,
        hasSubmittedActiveExam: hasSubmittedActiveExam,
        stats: DashboardStatsModel(
          totalBattles: totalBattles,
          averageScore: averageScore,
          rank: groupRank,
          totalCorrect: totalCorrect,
          totalWrong: totalWrong,
          streakCount: streakCount,
          highestStreak: highestStreak,
          weeklyActiveDays: weeklyActiveDaysList,
          unreadNotificationsCount: unreadNotificationsCount,
        ),
        leaderboard: leaderboard,
        groupRank: groupRank,
        globalRank: globalRank,
        lastExamTitle: lastCompletedExam?.title,
        lastExamId: lastCompletedExam?.id,
        latestPerformance: latestPerformance,
        isPremium: isPremiumFallback,
      );
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
