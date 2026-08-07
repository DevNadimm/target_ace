part of 'leaderboard_cubit.dart';

sealed class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardSuccess extends LeaderboardState {
  final List<Map<String, dynamic>> leaderboard;
  LeaderboardSuccess(this.leaderboard);
}

class LeaderboardFailure extends LeaderboardState {
  final String? message;
  final ErrorType? errorType;
  LeaderboardFailure([this.message, this.errorType]);
}