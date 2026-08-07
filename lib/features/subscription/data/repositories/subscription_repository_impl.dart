import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:target_ace/features/subscription/data/models/subscription_model.dart';
import 'package:target_ace/features/subscription/domain/entities/subscription_entity.dart';
import 'package:target_ace/features/subscription/domain/repository/subscription_repository.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  final SupabaseClient supabaseClient;

  const SubscriptionRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
    this.supabaseClient,
  );

  @override
  Future<Either<Failure, SubscriptionEntity>> fetchMySubscription() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }

      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return right(const SubscriptionModel(status: 'none'));
      }

      final profileResp = await supabaseClient
          .from('profiles')
          .select('is_premium, premium_expires_at')
          .eq('id', userId)
          .maybeSingle();

      final isPremium = profileResp?['is_premium'] as bool? ?? false;
      final expiryStr = profileResp?['premium_expires_at'] as String?;
      final bool isExpired = expiryStr != null && DateTime.tryParse(expiryStr)?.isBefore(DateTime.now()) == true;

      if (isPremium && !isExpired) {
        final approvedSub = await remoteDataSource.fetchLatestApprovedSubscription(userId);

        if (approvedSub != null) {
          final isTrial = approvedSub.planId == 'free_trial' || approvedSub.planName == 'Free Trial';
          return right(SubscriptionModel(
            status: isTrial ? 'trial' : 'active',
            planId: approvedSub.planId,
            planName: approvedSub.planName,
            startDate: approvedSub.startDate,
            endDate: approvedSub.endDate,
            isTrial: isTrial,
          ));
        }

        return right(SubscriptionModel(
          status: 'active',
          planId: 'premium',
          planName: 'Premium Monthly',
          startDate: DateTime.now().toIso8601String(),
          endDate: expiryStr ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        ));
      } else {
        final latestSub = await remoteDataSource.fetchLatestSubscription(userId);

        if (latestSub != null && latestSub.status == 'pending') {
          return right(SubscriptionModel(
            status: 'pending_verification',
            planId: latestSub.planId,
            planName: latestSub.planName,
          ));
        }

        if (isExpired) {
          return right(const SubscriptionModel(status: 'expired'));
        }
      }

      return right(const SubscriptionModel(status: 'none'));
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkTrialEligibility(String userId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final isEligible = await remoteDataSource.checkTrialEligibility(userId);
      return right(isEligible);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateFreeTrial({
    required String userId,
    required String userEmail,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      await remoteDataSource.activateFreeTrial(userId: userId, userEmail: userEmail);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}