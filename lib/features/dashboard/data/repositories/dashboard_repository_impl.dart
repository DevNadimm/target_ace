import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:target_ace/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:target_ace/features/dashboard/domain/repository/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  DashboardRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Stream<void> get dashboardRealtimeChanges => remoteDataSource.dashboardRealtimeChanges;

  @override
  Future<Either<Failure, DashboardEntity>> getDashboard() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }

      final goalId = await AppPreferences.getUserGoal();
      String groupId = await AppPreferences.getActiveGroupId();
      final userId = await AppPreferences.getUserId();

      if (groupId.isEmpty) {
        groupId = await AppPreferences.getUserGroup();
      }

      final dashboard = await remoteDataSource.getDashboard(
        goalId: goalId,
        groupId: groupId,
        userId: userId,
      );



      return right(dashboard);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupLeaderboard(String groupId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.'));
      }
      final leaderboard = await remoteDataSource.getGroupLeaderboard(groupId);
      return right(leaderboard);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
