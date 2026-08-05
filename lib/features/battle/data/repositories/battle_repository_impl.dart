import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/battle/data/datasources/battle_remote_datasource.dart';
import 'package:target_ace/features/battle/data/models/leaderboard_entry_model.dart';
import 'package:target_ace/features/battle/data/models/user_submission_model.dart';
import 'package:target_ace/features/battle/data/models/battle_model.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/battle_submission_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_data_entity.dart';
import 'package:target_ace/features/battle/domain/entities/battle_leaderboard_data_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/domain/entities/battle_arena_data_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/practice/data/models/question_model.dart';

class BattleRepositoryImpl implements BattleRepository {
  final BattleRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const BattleRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, List<BattleEntity>>> getBattles(String goalId, String groupId) async {
    try {
      // Clear old exam questions cache to prevent storage bloat
      await AppPreferences.clearCachedExamQuestions();
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final exams = await remoteDataSource.getBattles(goalId, groupId);
      return right(exams);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BattleSubmissionEntity?>> checkSubmission(String examId, String userId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final submission = await remoteDataSource.checkSubmission(examId, userId);
      return right(submission);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> fetchQuestions(String examId) async {
    try {
      if (!await connectionChecker.isConnected) {
        final cachedJson = await AppPreferences.getCachedExamQuestions(examId);
        if (cachedJson.isNotEmpty) {
          final cachedQuestions = cachedJson.map((q) => QuestionModel.fromJson(q)).toList();
          return right(cachedQuestions);
        }
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final questions = await remoteDataSource.fetchQuestions(examId);
      if (questions.isNotEmpty) {
        final rawList = questions.map((q) => q.toJson()).toList();
        await AppPreferences.saveCachedExamQuestions(examId, rawList);
      }
      return right(questions);
    } on ServerException catch (e) {
      final cachedJson = await AppPreferences.getCachedExamQuestions(examId);
      if (cachedJson.isNotEmpty) {
        final cachedQuestions = cachedJson.map((q) => QuestionModel.fromJson(q)).toList();
        return right(cachedQuestions);
      }
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitBattle({
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
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      await remoteDataSource.submitBattle(
        examId: examId,
        userId: userId,
        score: score,
        correctCount: correctCount,
        wrongCount: wrongCount,
        unansweredCount: unansweredCount,
        answers: answers,
        disqualified: disqualified,
        startedAt: startedAt,
        completedAt: completedAt,
        timeTakenSeconds: timeTakenSeconds,
        deviceInfo: deviceInfo,
        appVersion: appVersion,
        isAutoSubmitted: isAutoSubmitted,
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LeaderboardDataEntity>> fetchLeaderboardAndRanks({
    required String examId,
    required String userId,
    required String activeGroupId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final results = await remoteDataSource.fetchLeaderboardAndRanks(
        examId: examId,
        userId: userId,
        activeGroupId: activeGroupId,
      );

      final jsonResponse = results[0];
      List<LeaderboardEntryEntity> leaderboardList = [];
      int myRank = 0;

      if (jsonResponse != null) {
        final data = jsonResponse as Map<String, dynamic>;
        myRank = data['my_rank'] as int? ?? 0;
        final list = data['leaderboard'] as List?;
        if (list != null) {
          leaderboardList = list.map((item) => LeaderboardEntryModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
        }
      }

      final int groupRank = (results[1] as num?)?.toInt() ?? 0;
      final int globalRank = (results[2] as num?)?.toInt() ?? 0;

      return right(LeaderboardDataEntity(
        examRank: myRank,
        groupRank: groupRank,
        globalRank: globalRank,
        leaderboard: leaderboardList,
      ));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserSubmissionEntity>>> getUserSubmissions(String userId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final submissions = await remoteDataSource.getUserSubmissions(userId);
      final mapped = submissions.map((s) => UserSubmissionModel.fromJson(s)).toList();
      return right(mapped);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BattleEntity>>> getGroupBattles(String groupId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final exams = await remoteDataSource.getGroupBattles(groupId);
      return right(exams);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BattleArenaDataEntity>> getBattleArenaData({
    required String userId,
    required String groupId,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final data = await remoteDataSource.getBattleArenaData(userId: userId, groupId: groupId);
      
      final activeExamMap = data['active_exam'] as Map<String, dynamic>?;
      final activeExam = activeExamMap != null ? BattleModel.fromJson(activeExamMap) : null;
      
      final hasSubmittedActive = data['has_submitted_active'] as bool? ?? false;
      
      final upcomingExamsRaw = data['upcoming_exams'] as List<dynamic>? ?? [];
      final upcomingExams = upcomingExamsRaw
          .map((e) => BattleModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
          
      final recentHistoryRaw = data['recent_history'] as List<dynamic>? ?? [];
      final recentHistory = recentHistoryRaw
          .map((s) => UserSubmissionModel.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();

      return right(BattleArenaDataEntity(
        activeExam: activeExam,
        hasSubmittedActive: hasSubmittedActive,
        upcomingExams: upcomingExams,
        recentHistory: recentHistory,
      ));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BattleLeaderboardDataEntity>> getBattleLeaderboardData(String examId, {String? userId}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final data = await remoteDataSource.getBattleLeaderboardData(examId, userId: userId);

      final examDetails = BattleModel.fromJson(data[0] as Map<String, dynamic>);
      final topSubmissions = (data[1] as List).map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        if (userId != null && userId.isNotEmpty) {
          map['is_current_user'] = (map['user_id'] == userId);
        }
        return LeaderboardEntryModel.fromJson(map);
      }).toList();

      LeaderboardEntryEntity? currentUserRecord;
      if (data[2] != null) {
        final map = Map<String, dynamic>.from(data[2] as Map);
        map['is_current_user'] = true;
        currentUserRecord = LeaderboardEntryModel.fromJson(map);
      }

      return right(BattleLeaderboardDataEntity(
        exam: examDetails,
        topSubmissions: topSubmissions,
        currentUserRecord: currentUserRecord,
      ));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getLeaderboardCache(String examId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final cache = await remoteDataSource.getLeaderboardCache(examId);
      final mapped = cache.map((c) => LeaderboardEntryModel.fromJson(c)).toList();
      return right(mapped);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}