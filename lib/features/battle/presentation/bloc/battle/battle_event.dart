part of 'battle_bloc.dart';

abstract class BattleEvent {}

class BattleLoadRequested extends BattleEvent {}

class BattleOptionSelected extends BattleEvent {
  final String option;
  BattleOptionSelected(this.option);
}

class BattleAnswerSubmitted extends BattleEvent {}

class BattleQuestionJumped extends BattleEvent {
  final int targetIndex;
  BattleQuestionJumped(this.targetIndex);
}

class BattleForceSubmitRequested extends BattleEvent {}

class BattleDisqualificationRequested extends BattleEvent {}

class BattleTimeTicked extends BattleEvent {
  final int secondsRemaining;
  BattleTimeTicked(this.secondsRemaining);
}