import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/features/practice/data/datasources/practice_remote_datasource.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';

import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/practice/data/models/subject_model.dart';
import 'package:target_ace/features/practice/data/models/topic_model.dart';
import 'package:target_ace/features/practice/data/models/question_model.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  final PracticeRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const PracticeRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<SubjectEntity>>> getSubjects(String groupId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final subjectsData = await remoteDataSource.getSubjects(groupId);
      final subjects = subjectsData.map((e) => SubjectModel.fromJson(e)).toList();
      return right(subjects);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> startPracticeSession({
    required String subjectId,
    String? topicId,
    int limit = 20,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final sessionData = await remoteDataSource.startPracticeSession(
        subjectId: subjectId,
        topicId: topicId,
        limit: limit,
      );
      return right(sessionData);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, List<TopicEntity>>> getTopics(String subjectId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final topicsData = await remoteDataSource.getTopics(subjectId);
      final topics = topicsData.map((e) => TopicModel.fromJson(e)).toList();
      return right(topics);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getSubjectQuestions({
    required String subjectId,
    String? topicId,
    int limit = 20,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final questionsData = await remoteDataSource.getSubjectQuestions(
        subjectId: subjectId,
        topicId: topicId,
        limit: limit,
      );
      final questions = questionsData.map((e) => QuestionModel.fromJson(e)).toList();
      return right(questions);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, void>> recordAttempts(List<Map<String, dynamic>> attempts) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      await remoteDataSource.recordAttempts(attempts);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPracticeDashboardData(String groupId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final summary = await remoteDataSource.getPracticeDashboardData(groupId);
      return right(summary);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleBookmark(String questionId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final isBookmarked = await remoteDataSource.toggleBookmark(questionId);
      return right(isBookmarked);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBookmarkedQuestionIds() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final ids = await remoteDataSource.getBookmarkedQuestionIds();
      return right(ids);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getBookmarkedQuestions() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final questionsData = await remoteDataSource.getBookmarkedQuestions();
      final questions = questionsData.map((e) => QuestionModel.fromJson(e)).toList();
      return right(questions);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getAttemptedQuestionIds(String subjectId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final ids = await remoteDataSource.getAttemptedQuestionIds(subjectId);
      return right(ids.toSet());
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }

  @override
  Future<Either<Failure, void>> submitReport(String questionId, String reportText) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      await remoteDataSource.submitReport(questionId, reportText);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    }
  }
}