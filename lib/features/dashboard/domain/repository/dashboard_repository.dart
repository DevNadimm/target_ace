import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/dashboard/domain/entities/dashboard_entity.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, DashboardEntity>> getDashboard();
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupLeaderboard(String groupId);
  Stream<void> get dashboardRealtimeChanges;
}
