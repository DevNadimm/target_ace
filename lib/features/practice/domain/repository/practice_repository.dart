import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';

import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

abstract interface class PracticeRepository {
  Future<Either<Failure, List<SubjectEntity>>> getSubjects(String groupId);
  Future<Either<Failure, List<TopicEntity>>> getTopics(String subjectId);
  Future<Either<Failure, Map<String, dynamic>>> startPracticeSession({
    required String subjectId,
    String? topicId,
    int limit = 20,
  });
  Future<Either<Failure, List<QuestionEntity>>> getSubjectQuestions({
    required String subjectId,
    String? topicId,
    int limit = 20,
  });
  Future<Either<Failure, void>> recordAttempts(List<Map<String, dynamic>> attempts);
  Future<Either<Failure, Map<String, dynamic>>> getPracticeDashboardData(String groupId);
  Future<Either<Failure, Set<String>>> getAttemptedQuestionIds(String subjectId);

  // Bookmark methods
  Future<Either<Failure, bool>> toggleBookmark(String questionId);
  Future<Either<Failure, List<String>>> getBookmarkedQuestionIds();
  Future<Either<Failure, List<QuestionEntity>>> getBookmarkedQuestions();
  
  // Report error
  Future<Either<Failure, void>> submitReport(String questionId, String reportText);
}