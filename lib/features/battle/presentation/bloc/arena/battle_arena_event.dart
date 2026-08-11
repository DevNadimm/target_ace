part of 'battle_arena_bloc.dart';

abstract class BattleArenaEvent {}

class BattleArenaFetchRequested extends BattleArenaEvent {
  final bool isSilent;
  BattleArenaFetchRequested({this.isSilent = false});
}

class BattleArenaReviewRequested extends BattleArenaEvent {
  final String examId;
  final List<dynamic> answers;
  BattleArenaReviewRequested(this.examId, this.answers);
}

class BattleArenaEnterRequested extends BattleArenaEvent {}