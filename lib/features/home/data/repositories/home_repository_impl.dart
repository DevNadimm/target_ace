import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/features/home/data/datasources/home_remote_datasource.dart';
import 'package:target_ace/features/home/domain/entities/home_entity.dart';
import 'package:target_ace/features/home/domain/repository/home_repository.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  HomeRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Stream<void> get homeRealtimeChanges => remoteDataSource.homeRealtimeChanges;

  @override
  Future<Either<Failure, HomeEntity>> getHome() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }

      final goalId = await UserLocalDataSource.getUserGoal();
      String groupId = await UserLocalDataSource.getUserGroupId();
      final userId = await UserLocalDataSource.getUserId();

      if (groupId.isEmpty) {
        groupId = await UserLocalDataSource.getUserGroupId();
      }

      final home = await remoteDataSource.getHome(
        goalId: goalId,
        groupId: groupId,
        userId: userId,
      );



      return right(home);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGroupLeaderboard(String groupId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(message: 'No internet connection. Please check your network.', type: ErrorType.network));
      }
      final leaderboard = await remoteDataSource.getGroupLeaderboard(groupId);
      return right(leaderboard);
    } on ServerException catch (e) {
      return left(Failure(message: e.message, type: e.type));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}