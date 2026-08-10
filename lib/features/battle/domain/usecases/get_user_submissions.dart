import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class GetUserSubmissions implements UseCase<List<UserSubmissionEntity>, GetUserSubmissionsParams> {
  final BattleRepository repository;
  const GetUserSubmissions(this.repository);

  @override
  Future<Either<Failure, List<UserSubmissionEntity>>> call(GetUserSubmissionsParams params) async {
    return await repository.getUserSubmissions(
      userId: params.userId,
      limit: params.limit,
      offset: (params.page - 1) * params.limit,
    );
  }
}

class GetUserSubmissionsParams {
  final String userId;
  final int limit;
  final int page;

  const GetUserSubmissionsParams({
    required this.userId,
    this.limit = 20,
    this.page = 1,
  });
}