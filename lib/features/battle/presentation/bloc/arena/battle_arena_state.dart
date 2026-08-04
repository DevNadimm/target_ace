part of 'battle_arena_bloc.dart';

abstract class BattleArenaState {}

class BattleArenaInitial extends BattleArenaState {}

class BattleArenaLoading extends BattleArenaState {}

class BattleArenaSuccess extends BattleArenaState {
  final String goalId;
  final String groupId;
  final List<BattleEntity> todayExams;
  final List<BattleEntity> upcomingExams;
  final List<UserSubmissionEntity> pastSubmissions;

  BattleArenaSuccess({
    required this.goalId,
    required this.groupId,
    required this.todayExams,
    required this.upcomingExams,
    required this.pastSubmissions,
  });
}

class BattleArenaFailure extends BattleArenaState {
  final String errorMessage;
  BattleArenaFailure(this.errorMessage);
}
