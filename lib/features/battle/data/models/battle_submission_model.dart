import 'package:target_ace/features/battle/domain/entities/battle_submission_entity.dart';

class BattleSubmissionModel extends BattleSubmissionEntity {
  const BattleSubmissionModel({
    required super.id,
    required super.disqualified,
    required super.score,
    required super.answers,
  });

  factory BattleSubmissionModel.fromJson(Map<String, dynamic> json) {
    return BattleSubmissionModel(
      id: json['id'] as String? ?? '',
      disqualified: json['disqualified'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      answers: json['answers'] as List<dynamic>? ?? const [],
    );
  }
}