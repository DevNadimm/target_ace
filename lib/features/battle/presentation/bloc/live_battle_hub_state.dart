part of 'live_battle_hub_bloc.dart';

abstract class LiveBattleHubState {}

class LiveBattleHubInitial extends LiveBattleHubState {}

class LiveBattleHubLoading extends LiveBattleHubState {}

class LiveBattleHubSuccess extends LiveBattleHubState {
  final String goalId;
  final String groupId;
  final List<Map<String, dynamic>> todayExams;
  final List<Map<String, dynamic>> upcomingExams;
  final List<Map<String, dynamic>> pastSubmissions;

  LiveBattleHubSuccess({
    required this.goalId,
    required this.groupId,
    required this.todayExams,
    required this.upcomingExams,
    required this.pastSubmissions,
  });
}

class LiveBattleHubFailure extends LiveBattleHubState {
  final String errorMessage;
  LiveBattleHubFailure(this.errorMessage);
}
