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
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  BattleHistoryLoaded({
    required super.submissions,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  BattleHistoryLoaded copyWith({
    List<UserSubmissionEntity>? submissions,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return BattleHistoryLoaded(
      submissions: submissions ?? this.submissions,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
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
