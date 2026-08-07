part of 'battle_history_bloc.dart';

abstract class BattleHistoryState {
  final List<UserSubmissionEntity> submissions;
  BattleHistoryState({this.submissions = const []});
}

class BattleHistoryInitial extends BattleHistoryState {}

class BattleHistoryLoading extends BattleHistoryState {
  BattleHistoryLoading({super.submissions});
}

class BattleHistoryLoaded extends BattleHistoryState {
  BattleHistoryLoaded({required super.submissions});
}

class BattleHistoryError extends BattleHistoryState {
  final String message;
  BattleHistoryError(this.message, {super.submissions});
}

class BattleHistoryReviewLoading extends BattleHistoryState {
  BattleHistoryReviewLoading({super.submissions});
}

class BattleHistoryReviewReady extends BattleHistoryState {
  final List<QuestionEntity> questions;
  final List<dynamic> userAnswers;
  
  BattleHistoryReviewReady({
    required this.questions,
    required this.userAnswers,
    required super.submissions,
  });
}

class BattleHistoryReviewError extends BattleHistoryState {
  final String message;
  BattleHistoryReviewError(this.message, {super.submissions});
}
