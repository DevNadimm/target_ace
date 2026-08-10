import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class GetBattleQuestions implements UseCase<List<QuestionEntity>, GetBattleQuestionsParams> {
  final BattleRepository repository;

  GetBattleQuestions(this.repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(GetBattleQuestionsParams params) async {
    return await repository.fetchQuestions(
      examId: params.examId,
      limit: params.fetchAll ? null : params.limit,
      offset: params.fetchAll ? null : (params.page - 1) * params.limit,
    );
  }
}

class GetBattleQuestionsParams {
  final String examId;
  final int limit;
  final int page;
  final bool fetchAll;

  const GetBattleQuestionsParams({
    required this.examId,
    this.limit = 10,
    this.page = 1,
    this.fetchAll = false,
  });
}