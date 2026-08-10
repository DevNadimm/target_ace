part of 'battle_review_bloc.dart';

abstract class BattleReviewEvent {}

class FetchReviewQuestionsEvent extends BattleReviewEvent {
  final String examId;
  FetchReviewQuestionsEvent(this.examId);
}

class FetchMoreReviewQuestionsEvent extends BattleReviewEvent {
  final String examId;
  FetchMoreReviewQuestionsEvent(this.examId);
}
