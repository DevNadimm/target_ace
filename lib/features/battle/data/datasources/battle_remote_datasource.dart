import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/base_remote_datasource.dart';
import 'package:target_ace/features/battle/data/models/battle_model.dart';
import 'package:target_ace/features/battle/data/models/battle_submission_model.dart';
import 'package:target_ace/features/practice/data/models/question_model.dart';

abstract interface class BattleRemoteDataSource {
  Future<List<BattleModel>> getBattles(String goalId, String groupId);

  Future<BattleSubmissionModel?> checkSubmission(String examId, String userId);

  Future<List<QuestionModel>> fetchQuestions(String examId);

  Future<void> submitBattle({
    required String examId,
    required String userId,
    required double score,
    required int correctCount,
    required int wrongCount,
    required int unansweredCount,
    required List<Map<String, dynamic>> answers,
    required bool disqualified,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeTakenSeconds,
    Map<String, dynamic>? deviceInfo,
    String? appVersion,
    bool isAutoSubmitted,
  });

  Future<List<dynamic>> fetchLeaderboardAndRanks({
    required String examId,
    required String userId,
    required String activeGroupId,
  });

  Future<List<Map<String, dynamic>>> getUserSubmissions(String userId);

  Future<List<BattleModel>> getGroupBattles(String groupId);

  Future<Map<String, dynamic>> getBattleArenaData({
    required String userId,
    required String groupId,
  });

  Future<List<dynamic>> getBattleLeaderboardData(
    String examId, {
    String? userId,
  });

  Future<List<Map<String, dynamic>>> getLeaderboardCache(String examId);
}

class BattleRemoteDataSourceImpl extends BaseRemoteDataSource implements BattleRemoteDataSource {
  const BattleRemoteDataSourceImpl(super.client);

  @override
  Future<List<BattleModel>> getBattles(String goalId, String groupId) async {
    try {
      final nowUtc = DateTime.now().toUtc();
      final response = await client
          .from('exams')
          .select()
          .eq('goal_id', goalId)
          .eq('group_id', groupId)
          .order('start_time', ascending: true);

      final list = (response as List)
          .map((json) => BattleModel.fromJson(json))
          .toList();

      final unendedExams = list.where((e) {
        final start = DateTime.tryParse(e.startTime)?.toUtc();
        if (start == null) return true;
        final endTime = start.add(Duration(minutes: e.durationMinutes));
        return endTime.isAfter(nowUtc);
      }).toList();

      if (unendedExams.isNotEmpty) {
        return unendedExams;
      }

      return list;
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<BattleSubmissionModel?> checkSubmission(
    String examId,
    String userId,
  ) async {
    try {
      final response = await client
          .from('exam_submissions')
          .select('id, disqualified, score, answers')
          .eq('exam_id', examId)
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return BattleSubmissionModel.fromJson(response);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<List<QuestionModel>> fetchQuestions(String examId) async {
    try {
      final response = await client
          .from('exam_questions')
          .select('questions(*)')
          .eq('exam_id', examId);

      final List<QuestionModel> questions = [];
      for (final eq in response) {
        final q = eq['questions'] as Map<String, dynamic>?;
        if (q != null) {
          questions.add(QuestionModel.fromJson(q));
        }
      }
      return questions;
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<void> submitBattle({
    required String examId,
    required String userId,
    required double score,
    required int correctCount,
    required int wrongCount,
    required int unansweredCount,
    required List<Map<String, dynamic>> answers,
    required bool disqualified,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeTakenSeconds,
    Map<String, dynamic>? deviceInfo,
    String? appVersion,
    bool isAutoSubmitted = false,
  }) async {
    try {
      final Map<String, dynamic> rpcParams = {
        'p_exam_id': examId,
        'p_user_id': userId,
        'p_answers': answers,
        'p_disqualified': disqualified,
        'p_started_at': startedAt?.toIso8601String(),
        'p_completed_at': completedAt?.toIso8601String(),
        'p_time_taken_seconds': timeTakenSeconds ?? 0,
        'p_device_info': deviceInfo ?? {},
        'p_app_version': appVersion,
        'p_is_auto_submitted': isAutoSubmitted,
      };

      await client.rpc('submit_battle_exam_secure', params: rpcParams);
    } catch (e) {
      // Fallback to direct upsert if RPC is unavailable during deployment transition
      try {
        final Map<String, dynamic> payload = {
          'exam_id': examId,
          'user_id': userId,
          'score': score,
          'correct_count': correctCount,
          'wrong_count': wrongCount,
          'unanswered_count': unansweredCount,
          'answers': answers,
          'disqualified': disqualified,
          'is_auto_submitted': isAutoSubmitted,
        };

        if (startedAt != null) {
          payload['started_at'] = startedAt.toIso8601String();
        }
        if (completedAt != null) {
          payload['completed_at'] = completedAt.toIso8601String();
        }
        if (timeTakenSeconds != null) {
          payload['time_taken_seconds'] = timeTakenSeconds;
        }
        if (deviceInfo != null) {
          payload['device_info'] = deviceInfo;
        }
        if (appVersion != null) {
          payload['app_version'] = appVersion;
        }

        await client
            .from('exam_submissions')
            .upsert(payload, onConflict: 'exam_id,user_id');
      } catch (fallbackError) {
        handleException(e);
      }
    }
  }

  @override
  Future<List<dynamic>> fetchLeaderboardAndRanks({
    required String examId,
    required String userId,
    required String activeGroupId,
  }) async {
    try {
      return await Future.wait([
        client.rpc(
          'get_exam_results_and_leaderboard',
          params: {'target_exam_id': examId, 'target_user_id': userId},
        ),
        client.rpc(
          'get_user_group_rank',
          params: {'target_user_id': userId, 'target_group_id': activeGroupId},
        ),
        client.rpc('get_user_global_rank', params: {'target_user_id': userId}),
      ]);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserSubmissions(String userId) async {
    try {
      final response = await client.rpc(
        'get_user_submissions_with_stats',
        params: {'p_user_id': userId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<List<BattleModel>> getGroupBattles(String groupId) async {
    try {
      final response = await client
          .from('exams')
          .select()
          .eq('group_id', groupId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => BattleModel.fromJson(json))
          .toList();
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getBattleArenaData({
    required String userId,
    required String groupId,
  }) async {
    try {
      final response = await client.rpc(
        'get_battle_arena_data',
        params: {'p_user_id': userId, 'p_group_id': groupId},
      );
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<List<dynamic>> getBattleLeaderboardData(
    String examId, {
    String? userId,
  }) async {
    try {
      final examQuery = client
          .from('exams')
          .select()
          .eq('id', examId)
          .maybeSingle();

      final leaderboardQuery = client
          .from('leaderboards')
          .select(
            'score, time_taken_seconds, rank, user_id, profiles(name, avatar_url)',
          )
          .eq('exam_id', examId)
          .order('score', ascending: false)
          .order('time_taken_seconds', ascending: true)
          .limit(50);

      final List<dynamic> results = await Future.wait([
        examQuery,
        leaderboardQuery,
        if (userId != null && userId.isNotEmpty)
          client
              .from('leaderboards')
              .select(
                'score, time_taken_seconds, rank, user_id, profiles(name, avatar_url)',
              )
              .eq('exam_id', examId)
              .eq('user_id', userId)
              .maybeSingle()
        else
          Future.value(null),
      ]);

      final List<Map<String, dynamic>> top50 = List<Map<String, dynamic>>.from(
        results[1] as List,
      );
      Map<String, dynamic>? currentUserRecord =
          results[2] as Map<String, dynamic>?;

      if (currentUserRecord != null) {
        final containsUser = top50.any(
          (element) => element['user_id'] == userId,
        );
        if (!containsUser) {
          int rank = (currentUserRecord['rank'] as num?)?.toInt() ?? 0;
          if (rank <= 0) {
            final score = (currentUserRecord['score'] as num).toDouble();
            final time = currentUserRecord['time_taken_seconds'] as int;

            final countResponse = await client
                .from('leaderboards')
                .select('id')
                .eq('exam_id', examId)
                .or(
                  'score.gt.$score,and(score.eq.$score,time_taken_seconds.lt.$time)',
                );

            rank = countResponse.length + 1;
            currentUserRecord['rank'] = rank;
          }
        }
      }

      return [results[0], top50, currentUserRecord];
    } catch (e) {
      handleException(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboardCache(String examId) async {
    try {
      final response = await client
          .from('leaderboards')
          .select('*, profiles(name, avatar_url)')
          .eq('exam_id', examId)
          .order('score', ascending: false)
          .order('time_taken_seconds', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      handleException(e);
    }
  }
}