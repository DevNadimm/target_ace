import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/entities/battle_submission_entity.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';

class CheckSubmission implements UseCase<BattleSubmissionEntity?, CheckSubmissionParams> {
  final BattleRepository repository;
  const CheckSubmission(this.repository);

  @override
  Future<Either<Failure, BattleSubmissionEntity?>> call(CheckSubmissionParams params) async {
    return await repository.checkSubmission(params.examId, params.userId);
  }
}

class CheckSubmissionParams {
  final String examId;
  final String userId;

  const CheckSubmissionParams({required this.examId, required this.userId});
}