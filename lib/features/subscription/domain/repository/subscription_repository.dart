import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/subscription/domain/entities/subscription_entity.dart';

abstract interface class SubscriptionRepository {
  Future<Either<Failure, SubscriptionEntity>> fetchMySubscription();
  Future<Either<Failure, bool>> checkTrialEligibility(String userId);
  Future<Either<Failure, void>> activateFreeTrial({required String userId, required String userEmail});
}