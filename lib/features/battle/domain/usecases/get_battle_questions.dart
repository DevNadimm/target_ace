import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class GetBattleQuestions implements UseCase<List<QuestionEntity>, String> {
  final BattleRepository repository;
  const GetBattleQuestions(this.repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(String examId) async {
    return await repository.fetchQuestions(examId);
  }
}