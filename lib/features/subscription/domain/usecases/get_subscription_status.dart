import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/subscription/domain/entities/subscription_entity.dart';
import 'package:target_ace/features/subscription/domain/repository/subscription_repository.dart';

class GetSubscriptionStatus implements UseCase<SubscriptionEntity, NoParams> {
  final SubscriptionRepository repository;
  const GetSubscriptionStatus(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(NoParams params) async {
    return await repository.fetchMySubscription();
  }
}
