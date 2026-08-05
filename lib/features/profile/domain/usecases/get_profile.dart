import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/entities/profile_entity.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;
  const GetProfile(this.repository);

  Stream<Either<Failure, ProfileEntity>> call(NoParams params) {
    return repository.getProfileData();
  }
}