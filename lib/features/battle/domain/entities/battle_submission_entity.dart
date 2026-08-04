import 'package:flutter/foundation.dart';

class BattleSubmissionEntity {
  final String id;
  final bool disqualified;
  final double score;
  final List<dynamic> answers;

  const BattleSubmissionEntity({
    required this.id,
    required this.disqualified,
    required this.score,
    required this.answers,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BattleSubmissionEntity &&
        other.id == id &&
        other.disqualified == disqualified &&
        other.score == score &&
        listEquals(other.answers, answers);
  }

  @override
  int get hashCode {
    return id.hashCode ^ disqualified.hashCode ^ score.hashCode ^ Object.hashAll(answers);
  }
}
