import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

class CheckPhoneUnique implements UseCase<bool, String> {
  final ProfileRepository repository;

  CheckPhoneUnique(this.repository);

  @override
  Future<Either<Failure, bool>> call(String phone) async {
    return await repository.checkPhoneUnique(phone);
  }
}