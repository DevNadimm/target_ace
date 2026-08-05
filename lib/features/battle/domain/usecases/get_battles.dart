import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetBattles implements UseCase<List<BattleEntity>, GetBattlesParams> {
  final BattleRepository repository;
  const GetBattles(this.repository);

  @override
  Future<Either<Failure, List<BattleEntity>>> call(GetBattlesParams params) async {
    return await repository.getBattles(params.goalId, params.groupId);
  }
}

class GetBattlesParams {
  final String goalId;
  final String groupId;

  const GetBattlesParams({required this.goalId, required this.groupId});
}