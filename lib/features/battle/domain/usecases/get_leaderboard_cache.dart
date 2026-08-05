import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetLeaderboardCache implements UseCase<List<LeaderboardEntryEntity>, String> {
  final BattleRepository repository;
  const GetLeaderboardCache(this.repository);

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> call(String examId) async {
    return await repository.getLeaderboardCache(examId);
  }
}