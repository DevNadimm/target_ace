import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

class GetBattleGroups implements UseCase<List<BattleGroupEntity>, String> {
  final ProfileRepository repository;
  const GetBattleGroups(this.repository);

  @override
  Future<Either<Failure, List<BattleGroupEntity>>> call(String goalId) async {
    return await repository.getBattleGroups(goalId);
  }
}