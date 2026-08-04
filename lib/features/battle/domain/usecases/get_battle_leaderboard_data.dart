import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/battle_leaderboard_data_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetBattleLeaderboardData implements UseCase<BattleLeaderboardDataEntity, GetBattleLeaderboardDataParams> {
  final BattleRepository repository;
  const GetBattleLeaderboardData(this.repository);

  @override
  Future<Either<Failure, BattleLeaderboardDataEntity>> call(GetBattleLeaderboardDataParams params) async {
    return await repository.getBattleLeaderboardData(params.examId, userId: params.userId);
  }
}

class GetBattleLeaderboardDataParams {
  final String examId;
  final String? userId;

  const GetBattleLeaderboardDataParams({required this.examId, this.userId});
}
