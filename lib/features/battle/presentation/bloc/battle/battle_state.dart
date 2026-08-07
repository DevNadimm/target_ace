part of 'battle_bloc.dart';

abstract class BattleState {}

class BattleInitial extends BattleState {}

class BattleLoading extends BattleState {}

class BattleError extends BattleState {
  final String? message;
  final ErrorType? errorType;
  BattleError([this.message, this.errorType]);
}

class BattleWaiting extends BattleState {
  final String examId;
  final String examTitle;
  final DateTime examStartTime;
  final int durationMinutes;
  final int waitingSecondsRemaining;

  BattleWaiting({
    required this.examId,
    required this.examTitle,
    required this.examStartTime,
    required this.durationMinutes,
    required this.waitingSecondsRemaining,
  });
}

class BattleActive extends BattleState {
  final String examId;
  final String examTitle;
  final List<QuestionEntity> questions;
  final int currentIndex;
  final String selectedOption;
  final int questionSecondsRemaining;
  final List<Map<String, dynamic>> userAnswersList;
  final double score;
  final double perQuestionMark;
  final double negativeMark;
  final int examDurationMinutes;
  final DateTime examStartTime;

  BattleActive({
    required this.examId,
    required this.examTitle,
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    required this.questionSecondsRemaining,
    required this.userAnswersList,
    required this.score,
    required this.perQuestionMark,
    required this.negativeMark,
    required this.examDurationMinutes,
    required this.examStartTime,
  });

  BattleActive copyWith({
    int? currentIndex,
    String? selectedOption,
    int? questionSecondsRemaining,
    List<Map<String, dynamic>>? userAnswersList,
    double? score,
  }) {
    return BattleActive(
      examId: examId,
      examTitle: examTitle,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: selectedOption ?? this.selectedOption,
      questionSecondsRemaining: questionSecondsRemaining ?? this.questionSecondsRemaining,
      userAnswersList: userAnswersList ?? this.userAnswersList,
      score: score ?? this.score,
      perQuestionMark: perQuestionMark,
      negativeMark: negativeMark,
      examDurationMinutes: examDurationMinutes,
      examStartTime: examStartTime,
    );
  }
}

class BattleAnalyzing extends BattleState {
  final String examId;
  final String examTitle;
  final DateTime examStartTime;
  final int examDurationMinutes;
  final int analyzingSecondsRemaining;
  final double score;
  final List<QuestionEntity> questions;
  final List<Map<String, dynamic>> userAnswersList;
  final bool isDisqualified;

  BattleAnalyzing({
    required this.examId,
    required this.examTitle,
    required this.examStartTime,
    required this.examDurationMinutes,
    required this.analyzingSecondsRemaining,
    required this.score,
    required this.questions,
    required this.userAnswersList,
    this.isDisqualified = false,
  });
}

class BattleScoreboard extends BattleState {
  final String examId;
  final String examTitle;
  final double score;
  final int examRank;
  final int groupRank;
  final int globalRank;
  final List<LeaderboardEntryEntity> leaderboard;
  final bool isDisqualified;
  final List<QuestionEntity> questions;
  final List<Map<String, dynamic>> userAnswersList;

  BattleScoreboard({
    required this.examId,
    required this.examTitle,
    required this.score,
    required this.examRank,
    required this.groupRank,
    required this.globalRank,
    required this.leaderboard,
    required this.isDisqualified,
    required this.questions,
    required this.userAnswersList,
  });
}