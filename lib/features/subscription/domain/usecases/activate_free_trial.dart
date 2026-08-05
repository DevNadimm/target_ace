import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/subscription/domain/repository/subscription_repository.dart';

class ActivateFreeTrialParams {
  final String userId;
  final String userEmail;

  const ActivateFreeTrialParams({
    required this.userId,
    required this.userEmail,
  });
}

class ActivateFreeTrial implements UseCase<void, ActivateFreeTrialParams> {
  final SubscriptionRepository repository;

  ActivateFreeTrial(this.repository);

  @override
  Future<Either<Failure, void>> call(ActivateFreeTrialParams params) async {
    return await repository.activateFreeTrial(
      userId: params.userId,
      userEmail: params.userEmail,
    );
  }
}