import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';

import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';

class GetSubjects implements UseCase<List<SubjectEntity>, String> {
  final PracticeRepository repository;
  const GetSubjects(this.repository);

  @override
  Future<Either<Failure, List<SubjectEntity>>> call(String groupId) async {
    return await repository.getSubjects(groupId);
  }
}