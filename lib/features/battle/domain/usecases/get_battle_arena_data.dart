import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/battle_arena_data_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetBattleArenaDataParams {
  final String userId;
  final String groupId;

  const GetBattleArenaDataParams({
    required this.userId,
    required this.groupId,
  });
}

class GetBattleArenaData implements UseCase<BattleArenaDataEntity, GetBattleArenaDataParams> {
  final BattleRepository repository;

  GetBattleArenaData(this.repository);

  @override
  Future<Either<Failure, BattleArenaDataEntity>> call(GetBattleArenaDataParams params) async {
    return await repository.getBattleArenaData(
      userId: params.userId,
      groupId: params.groupId,
    );
  }
}
