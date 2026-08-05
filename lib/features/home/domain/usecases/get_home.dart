import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/home/domain/entities/home_entity.dart';
import 'package:target_ace/features/home/domain/repository/home_repository.dart';

class GetHome implements UseCase<HomeEntity, NoParams> {
  final HomeRepository repository;

  const GetHome(this.repository);

  @override
  Future<Either<Failure, HomeEntity>> call(NoParams params) async {
    return await repository.getHome();
  }
}