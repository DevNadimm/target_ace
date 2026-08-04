import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/notification/domain/entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, void>> storeFcmToken({required String userId, required String token});
  Future<Either<Failure, List<NotificationEntity>>> fetchNotifications({int page = 1, int limit = 20});
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String id);
  Future<Either<Failure, void>> deleteAllNotifications();
}
