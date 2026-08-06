import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/auth/domain/repository/auth_repository.dart';

class DoLocalLogout implements UseCase<void, NoParams> {
  final AuthRepository repository;
  const DoLocalLogout(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.localLogout();
  }
}
