import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:target_ace/features/notification/domain/entities/notification_entity.dart';
import 'package:target_ace/features/notification/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  const NotificationRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, void>> storeFcmToken({required String userId, required String token}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      await remoteDataSource.storeFcmToken(userId: userId, token: token);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final list = await remoteDataSource.fetchNotifications(page: page, limit: limit);
      return right(list);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      await remoteDataSource.markAsRead(id);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      await remoteDataSource.markAllAsRead();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String id) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      await remoteDataSource.deleteNotification(id);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      await remoteDataSource.deleteAllNotifications();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}