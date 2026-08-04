import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_data_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetLeaderboardAndRanks implements UseCase<LeaderboardDataEntity, GetLeaderboardAndRanksParams> {
  final BattleRepository repository;
  const GetLeaderboardAndRanks(this.repository);

  @override
  Future<Either<Failure, LeaderboardDataEntity>> call(GetLeaderboardAndRanksParams params) async {
    return await repository.fetchLeaderboardAndRanks(
      examId: params.examId,
      userId: params.userId,
      activeGroupId: params.activeGroupId,
    );
  }
}

class GetLeaderboardAndRanksParams {
  final String examId;
  final String userId;
  final String activeGroupId;

  const GetLeaderboardAndRanksParams({
    required this.examId,
    required this.userId,
    required this.activeGroupId,
  });
}
