import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:target_ace/features/dashboard/domain/repository/dashboard_repository.dart';

class GetDashboard implements UseCase<DashboardEntity, NoParams> {
  final DashboardRepository repository;

  const GetDashboard(this.repository);

  @override
  Future<Either<Failure, DashboardEntity>> call(NoParams params) async {
    return await repository.getDashboard();
  }
}
