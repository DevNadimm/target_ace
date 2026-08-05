import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetUserSubmissions implements UseCase<List<UserSubmissionEntity>, String> {
  final BattleRepository repository;
  const GetUserSubmissions(this.repository);

  @override
  Future<Either<Failure, List<UserSubmissionEntity>>> call(String userId) async {
    return await repository.getUserSubmissions(userId);
  }
}