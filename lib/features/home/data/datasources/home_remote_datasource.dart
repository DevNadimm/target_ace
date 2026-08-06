import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/base_remote_datasource.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/home/data/models/home_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<HomeModel> getHome({
    required String goalId,
    required String groupId,
    required String userId,
  });
  Future<List<Map<String, dynamic>>> getGroupLeaderboard(String groupId);
  Stream<void> get homeRealtimeChanges;
}

class HomeRemoteDataSourceImpl extends BaseRemoteDataSource implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(super.client);

  @override
  Stream<void> get homeRealtimeChanges {
    late StreamController<void> controller;
    RealtimeChannel? examsChannel;
    RealtimeChannel? submissionsChannel;

    controller = StreamController<void>.broadcast(
      onListen: () {
        examsChannel = client
            .channel('public-exams-home')
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

        submissionsChannel = client
            .channel('public-submissions-home')
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
          client.removeChannel(examsChannel!);
        }
        if (submissionsChannel != null) {
          client.removeChannel(submissionsChannel!);
        }
      },
    );

    return controller.stream;
  }

  @override
  Future<List<Map<String, dynamic>>> getGroupLeaderboard(String groupId) async {
    try {
      final response = await client
          .from('group_leaderboard')
          .select()
          .eq('group_id', groupId)
          .order('total_score', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<HomeModel> getHome({
    required String goalId,
    required String groupId,
    required String userId,
  }) async {
    try {
      if (goalId.isEmpty) {
        return HomeModel.empty();
      }

      final targetGroupId = groupId.isEmpty ? goalId : groupId;

      // ── Single Atomic RPC Call (1 HTTP RTT) ──
      try {
        final resp = await client.rpc('get_user_home_summary', params: {
          'target_user_id': userId,
          'target_group_id': targetGroupId,
        });

        if (resp != null && resp is Map<String, dynamic>) {
          final activeExamMap = resp['active_exam'] as Map<String, dynamic>?;
          final activeExam = activeExamMap != null ? HomeExamModel.fromJson(activeExamMap) : null;
          final hasSubmittedActive = resp['has_submitted_active'] as bool? ?? false;
          final isPremium = resp['is_premium'] as bool? ?? false;
          final planName = resp['plan_name'] as String? ?? 'Free Member';
          final subStatus = resp['subscription_status'] as String? ?? 'none';
          final expiryStr = resp['premium_expires_at'] as String?;
          final groupLockedUntilStr = resp['group_locked_until'] as String?;

          final Map<String, dynamic> localUpdates = {
            'subscription_plan_name': planName,
            'subscription_status': subStatus,
            'subscription_expiry_date': expiryStr ?? '',
          };
          if (groupLockedUntilStr != null && groupLockedUntilStr.isNotEmpty) {
            localUpdates['group_locked_until'] = groupLockedUntilStr;
          }

          await UserLocalDataSource.updateFields(localUpdates);

          final totalBattles = (resp['total_battles'] as num? ?? 0).toInt();
          final averageScore = (resp['average_score'] as num? ?? 0.0).toDouble();
          final totalCorrect = (resp['total_correct'] as num? ?? 0).toInt();
          final totalWrong = (resp['total_wrong'] as num? ?? 0).toInt();
          final groupRank = (resp['group_rank'] as num? ?? 0).toInt();
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

          final lastCompletedExamMap = resp['last_completed_exam'] as Map<String, dynamic>?;
          final lastCompletedExam = lastCompletedExamMap != null ? HomeExamModel.fromJson(lastCompletedExamMap) : null;

          final leaderboardList = resp['leaderboard'] as List? ?? [];
          final List<LeaderboardItemModel> leaderboard = [];
          for (int i = 0; i < leaderboardList.length; i++) {
            final item = leaderboardList[i];
            final name = item['name'] as String? ?? 'Student';
            final avatarUrl = item['avatar_url'] as String?;
            final subUserId = item['user_id'] as String? ?? '';
            leaderboard.add(
              LeaderboardItemModel(
                rank: i + 1,
                name: name,
                score: (item['score'] as num? ?? 0).toDouble(),
                avatarUrl: avatarUrl,
                isCurrentUser: subUserId == userId,
              ),
            );
          }

          // Local mock if leaderboard is empty
          if (leaderboard.isEmpty) {
            leaderboard.addAll([
              LeaderboardItemModel(rank: 1, name: 'Rafiq Ahmed', score: 98),
              LeaderboardItemModel(rank: 2, name: 'Sadia Islam', score: 95),
              LeaderboardItemModel(rank: 3, name: 'Tanvir Hasan', score: 91),
            ]);
          }

          return HomeModel(
            activeExam: activeExam,
            hasSubmittedActiveExam: hasSubmittedActive,
            stats: HomeStatsModel(
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
            lastExamTitle: lastCompletedExam?.title,
            lastExamId: lastCompletedExam?.id,
            latestPerformance: latestPerformance,
            isPremium: isPremium,
          );
        } else {
          throw const ServerException(message: 'Invalid home response from server.');
        }
      } catch (e) {
        handleException(e);
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      handleException(e);
    }
  }
}