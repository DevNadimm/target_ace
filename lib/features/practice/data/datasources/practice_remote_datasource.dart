import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';

abstract interface class PracticeRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSubjects(String groupId);
  Future<Map<String, dynamic>> startPracticeSession({
    required String subjectId,
    String? topicId,
    int limit = 20,
  });
  Future<List<Map<String, dynamic>>> getTopics(String subjectId);
  Future<List<Map<String, dynamic>>> getSubjectQuestions({
    required String subjectId,
    String? topicId,
    int limit = 20,
  });
  Future<void> recordAttempts(List<Map<String, dynamic>> attempts);
  Future<Map<String, dynamic>> getPracticeDashboardData(String groupId);
  Future<List<String>> getAttemptedQuestionIds(String subjectId);

  // Bookmark methods
  Future<bool> toggleBookmark(String questionId);
  Future<List<String>> getBookmarkedQuestionIds();
  Future<List<Map<String, dynamic>>> getBookmarkedQuestions();
  Future<void> submitReport(String questionId, String reportText);
}

class PracticeRemoteDataSourceImpl implements PracticeRemoteDataSource {
  final SupabaseClient _client;
  const PracticeRemoteDataSourceImpl(this._client);

  @override
  Future<List<Map<String, dynamic>>> getSubjects(String groupId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(message: 'User not authenticated');
      }
      final response = await _client.rpc('get_subjects_with_progress', params: {
        'p_group_id': groupId,
        'p_user_id': userId,
      });
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> startPracticeSession({
    required String subjectId,
    String? topicId,
    int limit = 20,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      final response = await _client.rpc('start_practice_session', params: {
        'p_user_id': userId,
        'p_subject_id': subjectId,
        'p_topic_id': topicId,
        'p_limit': limit,
      });

      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopics(String subjectId) async {
    try {
      final response = await _client
          .from('topics')
          .select()
          .eq('subject_id', subjectId)
          .order('display_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSubjectQuestions({
    required String subjectId,
    String? topicId,
    int limit = 20,
  }) async {
    try {
      var query = _client.from('questions').select().eq('subject_id', subjectId);
      if (topicId != null) {
        query = query.eq('topic_id', topicId);
      }
      final response = await query.limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> recordAttempts(List<Map<String, dynamic>> attempts) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      if (attempts.isEmpty) return;

      final attemptsToInsert = attempts.map((a) => {
            ...a,
            'user_id': userId,
          }).toList();

      await _client.from('practice_attempts').insert(attemptsToInsert);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getPracticeDashboardData(String groupId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client.rpc('get_practice_summary', params: {
        'target_user_id': userId,
        'target_group_id': groupId,
      });
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> toggleBookmark(String questionId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      final response = await _client.rpc('toggle_bookmark', params: {
        'p_user_id': userId,
        'p_question_id': questionId,
      });

      return response as bool;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getBookmarkedQuestionIds() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('bookmarked_questions')
          .select('question_id')
          .eq('user_id', userId);

      return (response as List)
          .map((row) => row['question_id'].toString())
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBookmarkedQuestions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('bookmarked_questions')
          .select('question_id, questions!inner(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => Map<String, dynamic>.from(row['questions'] as Map))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getAttemptedQuestionIds(String subjectId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('practice_attempts')
          .select('question_id')
          .eq('user_id', userId)
          .eq('subject_id', subjectId);

      return (response as List)
          .map((row) => row['question_id'].toString())
          .toSet()
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> submitReport(String questionId, String reportText) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const ServerException(message: 'User not authenticated');

      await _client.from('question_reports').insert({
        'user_id': userId,
        'question_id': questionId,
        'report_text': reportText,
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}