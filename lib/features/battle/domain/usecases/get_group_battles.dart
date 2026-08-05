import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetGroupBattles implements UseCase<List<BattleEntity>, String> {
  final BattleRepository repository;
  const GetGroupBattles(this.repository);

  @override
  Future<Either<Failure, List<BattleEntity>>> call(String groupId) async {
    return await repository.getGroupBattles(groupId);
  }
}