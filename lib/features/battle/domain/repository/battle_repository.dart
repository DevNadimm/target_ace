import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/battle_submission_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_data_entity.dart';
import 'package:target_ace/features/battle/domain/entities/battle_leaderboard_data_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/battle/domain/entities/battle_arena_data_entity.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

abstract interface class BattleRepository {
  Future<Either<Failure, List<BattleEntity>>> getBattles(String goalId, String groupId);
  Future<Either<Failure, BattleSubmissionEntity?>> checkSubmission(String examId, String userId);
  Future<Either<Failure, List<QuestionEntity>>> fetchQuestions(String examId);
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
    bool isAutoSubmitted,
  });
  Future<Either<Failure, LeaderboardDataEntity>> fetchLeaderboardAndRanks({
    required String examId,
    required String userId,
    required String activeGroupId,
  });
  Future<Either<Failure, List<UserSubmissionEntity>>> getUserSubmissions(String userId);
  Future<Either<Failure, List<BattleEntity>>> getGroupBattles(String groupId);
  Future<Either<Failure, BattleArenaDataEntity>> getBattleArenaData({required String userId, required String groupId});
  Future<Either<Failure, BattleLeaderboardDataEntity>> getBattleLeaderboardData(String examId, {String? userId});
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getLeaderboardCache(String examId);
}