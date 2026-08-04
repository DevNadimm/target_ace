import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/notification/domain/entities/notification_entity.dart';
import 'package:target_ace/features/notification/domain/repository/notification_repository.dart';

class GetNotificationsParams {
  final int page;
  final int limit;

  const GetNotificationsParams({
    this.page = 1,
    this.limit = 20,
  });
}

class GetNotifications implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository repository;
  const GetNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(GetNotificationsParams params) async {
    return await repository.fetchNotifications(
      page: params.page,
      limit: params.limit,
    );
  }
}
