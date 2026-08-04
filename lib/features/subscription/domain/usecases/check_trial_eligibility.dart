import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/subscription/domain/repository/subscription_repository.dart';

class CheckTrialEligibility implements UseCase<bool, String> {
  final SubscriptionRepository repository;

  CheckTrialEligibility(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.checkTrialEligibility(userId);
  }
}
