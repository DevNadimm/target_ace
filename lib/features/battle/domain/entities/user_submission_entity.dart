import 'package:flutter/foundation.dart';

class UserSubmissionEntity {
  final String submissionId;
  final String examId;
  final String examTitle;
  final String completedAt;
  final double score;
  final bool disqualified;
  final int correctCount;
  final int wrongCount;
  final int unansweredCount;
  final List<dynamic> answers;
  final bool isLocked;

  final int rank;
  final int totalParticipants;
  final int timeTakenSeconds;

  const UserSubmissionEntity({
    required this.submissionId,
    required this.examId,
    required this.examTitle,
    required this.completedAt,
    required this.score,
    required this.disqualified,
    required this.correctCount,
    required this.wrongCount,
    required this.unansweredCount,
    required this.answers,
    this.isLocked = false,
    this.rank = 0,
    this.totalParticipants = 0,
    this.timeTakenSeconds = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSubmissionEntity &&
        other.submissionId == submissionId &&
        other.examId == examId &&
        other.examTitle == examTitle &&
        other.completedAt == completedAt &&
        other.score == score &&
        other.disqualified == disqualified &&
        other.correctCount == correctCount &&
        other.wrongCount == wrongCount &&
        other.unansweredCount == unansweredCount &&
        other.isLocked == isLocked &&
        listEquals(other.answers, answers);
  }

  @override
  int get hashCode {
    return submissionId.hashCode ^
        examId.hashCode ^
        examTitle.hashCode ^
        completedAt.hashCode ^
        score.hashCode ^
        disqualified.hashCode ^
        correctCount.hashCode ^
        wrongCount.hashCode ^
        unansweredCount.hashCode ^
        isLocked.hashCode ^
        Object.hashAll(answers);
  }
}