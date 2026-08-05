import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/services/notification_service.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/core/common/models/cached_user_model.dart';
import 'package:target_ace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:target_ace/features/auth/domain/entities/auth_result.dart';
import 'package:target_ace/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  final NotificationService notificationService;

  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
    this.notificationService,
  );

  @override
  Future<Either<Failure, AuthResult>> googleSignIn() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }

      final userModel = await remoteDataSource.googleSignIn();
      final profile = await remoteDataSource.fetchProfile(userModel.id);

      final supabaseUser = remoteDataSource.currentUser!;
      final subscription = profile['subscription'] as Map<String, dynamic>?;

      // Build and save unified cached user â€” single write
      final cachedUser = CachedUserModel.fromRpcPayload(
        profile: profile,
        subscription: subscription,
        supabaseUser: supabaseUser,
      );
      await UserLocalDataSource.saveUser(cachedUser);

      // Setup FCM topics and tokens asynchronously
      notificationService.subscribeForUser(
        userId: userModel.id,
        groupId: cachedUser.groupId,
      ).catchError((_) {});

      final token = remoteDataSource.currentSession?.accessToken ?? '';

      AuthSubscription? authSubscription;
      if (subscription != null) {
        authSubscription = AuthSubscription(
          status: subscription['status'] as String? ?? 'none',
          planId: subscription['plan_id']?.toString(),
          planName: subscription['plan_name'] as String?,
          startDate: subscription['start_date'] as String?,
          endDate: subscription['end_date'] as String?,
          daysRemaining: subscription['days_remaining'] as int?,
          isTrial: subscription['is_trial'] as bool? ?? false,
        );
      }

      return right(AuthResult(
        success: true,
        message: 'Sign-in successful',
        token: token,
        user: userModel,
        subscription: authSubscription,
      ));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Run FCM unsubscribe asynchronously so a blocked Firebase request doesn't halt user logout.
      notificationService.handleLogout().catchError((_) {});
      
      await remoteDataSource.logout();
      await UserLocalDataSource.clear();
      await AppPreferences.clearAll();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncProfile() async {
    try {
      final user = remoteDataSource.currentUser;
      if (user == null) {
        return left(Failure(message: 'User is not logged in.'));
      }

      final profile = await remoteDataSource.fetchProfile(user.id);
      final subscription = profile['subscription'] as Map<String, dynamic>?;

      // Build and save unified cached user â€” single write
      final cachedUser = CachedUserModel.fromRpcPayload(
        profile: profile,
        subscription: subscription,
        supabaseUser: user,
      );
      await UserLocalDataSource.saveUser(cachedUser);

      // Setup FCM topics and tokens asynchronously on profile sync
      notificationService.subscribeForUser(
        userId: user.id,
        groupId: cachedUser.groupId,
      ).catchError((_) {});

      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}