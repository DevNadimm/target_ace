import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

class GetOnboardingGoals implements UseCase<List<OnboardingGoalEntity>, NoParams> {
  final ProfileRepository repository;
  const GetOnboardingGoals(this.repository);

  @override
  Future<Either<Failure, List<OnboardingGoalEntity>>> call(NoParams params) async {
    return await repository.getOnboardingGoals();
  }
}
