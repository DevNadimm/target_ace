import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/notification/domain/repository/notification_repository.dart';

class StoreFcmToken implements UseCase<void, StoreFcmTokenParams> {
  final NotificationRepository repository;
  const StoreFcmToken(this.repository);

  @override
  Future<Either<Failure, void>> call(StoreFcmTokenParams params) async {
    return await repository.storeFcmToken(userId: params.userId, token: params.token);
  }
}

class StoreFcmTokenParams {
  final String userId;
  final String token;
  StoreFcmTokenParams({required this.userId, required this.token});
}
