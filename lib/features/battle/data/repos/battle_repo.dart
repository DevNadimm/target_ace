import 'package:supabase_flutter/supabase_flutter.dart';

class BattleRepo {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch active or upcoming exams today for a specific goal and group.
  static Future<List<Map<String, dynamic>>> getExams(String goalId, String groupId) async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    final response = await _client
        .from('exams')
        .select()
        .eq('goal_id', goalId)
        .eq('group_id', groupId)
        .gte('start_time', cutoff.toIso8601String())
        .order('start_time', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch all submissions of a user with linked exam details and participant counts.
  static Future<List<Map<String, dynamic>>> getUserSubmissions(String userId) async {
    final response = await _client.rpc(
      'get_user_submissions_with_stats',
      params: {'p_user_id': userId},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch all exams of a group.
  static Future<List<Map<String, dynamic>>> getGroupExams(String groupId) async {
    final response = await _client
        .from('exams')
        .select()
        .eq('group_id', groupId)
        .order('start_time', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch leaderboard and details of a specific exam.
  static Future<List<dynamic>> getExamLeaderboardData(String examId) async {
    return Future.wait([
      _client.from('exams').select().eq('id', examId).maybeSingle(),
      _client
          .from('exam_submissions')
          .select('score, correct_count, wrong_count, user_id, profiles(name, avatar_url)')
          .eq('exam_id', examId)
          .order('score', ascending: false)
    ]);
  }

  /// Check if the user has already submitted this exam.
  static Future<List<Map<String, dynamic>>> checkSubmission(String examId, String userId) async {
    final response = await _client
        .from('exam_submissions')
        .select('id, disqualified, score, answers')
        .eq('exam_id', examId)
        .eq('user_id', userId)
        .limit(1);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch questions linked to an exam.
  static Future<List<Map<String, dynamic>>> fetchQuestions(String examId) async {
    final response = await _client
        .from('exam_questions')
        .select('questions(*)')
        .eq('exam_id', examId);
    
    final List<Map<String, dynamic>> questions = [];
    for (final eq in response) {
      final q = eq['questions'] as Map<String, dynamic>?;
      if (q != null) {
        questions.add(q);
      }
    }
    return questions;
  }

  /// Upsert exam submission/attempt results with anti-cheat metadata.
  static Future<void> submitExam({
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

    if (startedAt != null) payload['started_at'] = startedAt.toIso8601String();
    if (completedAt != null) payload['completed_at'] = completedAt.toIso8601String();
    if (timeTakenSeconds != null) payload['time_taken_seconds'] = timeTakenSeconds;
    if (deviceInfo != null) payload['device_info'] = deviceInfo;
    if (appVersion != null) payload['app_version'] = appVersion;

    await _client.from('exam_submissions').upsert(payload, onConflict: 'exam_id,user_id');
  }

  /// Fetch fast cached leaderboard for an exam (sub-100ms response time).
  static Future<List<Map<String, dynamic>>> getLeaderboardCache(String examId) async {
    final response = await _client
        .from('leaderboards')
        .select('*, profiles(name, avatar_url)')
        .eq('exam_id', examId)
        .order('score', ascending: false)
        .order('time_taken_seconds', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Call parallel database functions to get leaderboard, group rank, and global rank.
  static Future<List<dynamic>> fetchLeaderboardAndRanks({
    required String examId,
    required String userId,
    required String activeGroupId,
  }) async {
    return Future.wait([
      _client.rpc('get_exam_results_and_leaderboard', params: {
        'target_exam_id': examId,
        'target_user_id': userId,
      }),
      _client.rpc('get_user_group_rank', params: {
        'target_user_id': userId,
        'target_group_id': activeGroupId,
      }),
      _client.rpc('get_user_global_rank', params: {
        'target_user_id': userId,
      }),
    ]);
  }

  /// Fetch subjects for an onboarding goal.
  static Future<List<Map<String, dynamic>>> getSubjects(String goalId) async {
    final response = await _client
        .from('subjects')
        .select()
        .eq('goal_id', goalId)
        .order('display_order', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch topics for a subject.
  static Future<List<Map<String, dynamic>>> getTopics(String subjectId) async {
    final response = await _client
        .from('topics')
        .select()
        .eq('subject_id', subjectId)
        .order('display_order', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch practice questions by subject and optional topic.
  static Future<List<Map<String, dynamic>>> getSubjectQuestions({
    required String subjectId,
    String? topicId,
    int limit = 20,
  }) async {
    var query = _client.from('questions').select().eq('subject_id', subjectId);
    if (topicId != null) {
      query = query.eq('topic_id', topicId);
    }
    final response = await query.limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch active subscription plans.
  static Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    final response = await _client
        .from('plans')
        .select()
        .eq('is_active', true)
        .order('price', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}
