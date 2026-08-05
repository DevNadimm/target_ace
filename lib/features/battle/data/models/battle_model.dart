import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';

class BattleModel extends BattleEntity {
  const BattleModel({
    required super.id,
    required super.title,
    required super.goalId,
    required super.groupId,
    required super.startTime,
    required super.endTime,
    required super.durationMinutes,
    required super.totalQuestions,
    required super.perQuestionMark,
    required super.negativeMark,
  });

  factory BattleModel.fromJson(Map<String, dynamic> json) {
    return BattleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      goalId: json['goal_id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      perQuestionMark: (json['per_question_mark'] as num?)?.toDouble() ?? 1.0,
      negativeMark: (json['negative_mark'] as num?)?.toDouble() ?? 0.25,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'goal_id': goalId,
      'group_id': groupId,
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'total_questions': totalQuestions,
      'per_question_mark': perQuestionMark,
      'negative_mark': negativeMark,
    };
  }
}