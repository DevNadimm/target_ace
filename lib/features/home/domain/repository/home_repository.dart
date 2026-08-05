import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/home/domain/entities/home_entity.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, HomeEntity>> getHome();
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupLeaderboard(String groupId);
  Stream<void> get homeRealtimeChanges;
}