import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class GetSubjectQuestions implements UseCase<List<QuestionEntity>, GetQuestionsParams> {
  final PracticeRepository repository;
  const GetSubjectQuestions(this.repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(GetQuestionsParams params) async {
    return await repository.getSubjectQuestions(
      subjectId: params.subjectId,
      topicId: params.topicId,
      limit: params.limit,
    );
  }
}

class GetQuestionsParams {
  final String subjectId;
  final String? topicId;
  final int limit;

  GetQuestionsParams({
    required this.subjectId,
    this.topicId,
    this.limit = 20,
  });
}
