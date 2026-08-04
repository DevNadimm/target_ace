import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/auth/domain/entities/auth_result.dart';
import 'package:target_ace/features/auth/domain/repository/auth_repository.dart';

class DoGoogleSignIn implements UseCase<AuthResult, NoParams> {
  final AuthRepository repository;
  const DoGoogleSignIn(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) async {
    return await repository.googleSignIn();
  }
}
