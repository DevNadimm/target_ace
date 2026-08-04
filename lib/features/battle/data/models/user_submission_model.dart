import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';

class UserSubmissionModel extends UserSubmissionEntity {
  const UserSubmissionModel({
    required super.submissionId,
    required super.examId,
    required super.examTitle,
    required super.completedAt,
    required super.score,
    required super.disqualified,
    required super.correctCount,
    required super.wrongCount,
    required super.unansweredCount,
    required super.answers,
    super.rank = 0,
    super.totalParticipants = 0,
    super.timeTakenSeconds = 0,
  });

  factory UserSubmissionModel.fromJson(Map<String, dynamic> json) {
    return UserSubmissionModel(
      submissionId: json['submission_id'] as String? ?? json['id'] as String? ?? '',
      examId: json['exam_id'] as String? ?? '',
      examTitle: json['exam_title'] as String? ?? '',
      completedAt: json['completed_at'] as String? ?? json['submitted_at'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      disqualified: json['disqualified'] as bool? ?? false,
      correctCount: json['correct_count'] as int? ?? 0,
      wrongCount: json['wrong_count'] as int? ?? 0,
      unansweredCount: json['unanswered_count'] as int? ?? 0,
      answers: json['answers'] as List<dynamic>? ?? const [],
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      totalParticipants: (json['total_participants'] as num?)?.toInt() ?? 0,
      timeTakenSeconds: (json['time_taken_seconds'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'submission_id': submissionId,
      'exam_id': examId,
      'exam_title': examTitle,
      'completed_at': completedAt,
      'score': score,
      'disqualified': disqualified,
      'correct_count': correctCount,
      'wrong_count': wrongCount,
      'unanswered_count': unansweredCount,
      'answers': answers,
    };
  }
}
