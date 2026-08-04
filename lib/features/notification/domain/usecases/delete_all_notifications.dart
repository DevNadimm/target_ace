import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/notification/domain/repository/notification_repository.dart';

class DeleteAllNotifications implements UseCase<void, NoParams> {
  final NotificationRepository repository;
  const DeleteAllNotifications(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllNotifications();
  }
}
