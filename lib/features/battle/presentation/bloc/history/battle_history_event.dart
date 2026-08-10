part of 'battle_history_bloc.dart';

sealed class BattleHistoryEvent {}

class FetchBattleHistoryEvent extends BattleHistoryEvent {
  final bool isRefresh;
  FetchBattleHistoryEvent({this.isRefresh = false});
}

class FetchMoreBattleHistoryEvent extends BattleHistoryEvent {}

class FetchBattleQuestionsEvent extends BattleHistoryEvent {
  final String examId;
  final List<dynamic> userAnswers;

  FetchBattleQuestionsEvent({
    required this.examId,
    required this.userAnswers,
  });
}
