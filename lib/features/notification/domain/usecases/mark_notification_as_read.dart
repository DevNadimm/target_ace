import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/notification/domain/repository/notification_repository.dart';

class MarkNotificationAsRead implements UseCase<void, String> {
  final NotificationRepository repository;
  const MarkNotificationAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.markAsRead(id);
  }
}