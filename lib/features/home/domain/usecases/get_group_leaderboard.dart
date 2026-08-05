import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/home/domain/repository/home_repository.dart';

class GetGroupLeaderboard implements UseCase<List<Map<String, dynamic>>, String> {
  final HomeRepository repository;

  const GetGroupLeaderboard(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(String groupId) async {
    return await repository.getGroupLeaderboard(groupId);
  }
}