import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';

import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';

class GetTopics implements UseCase<List<TopicEntity>, String> {
  final PracticeRepository repository;
  const GetTopics(this.repository);

  @override
  Future<Either<Failure, List<TopicEntity>>> call(String subjectId) async {
    return await repository.getTopics(subjectId);
  }
}
