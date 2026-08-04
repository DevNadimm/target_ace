class BattleEntity {
  final String id;
  final String title;
  final String goalId;
  final String groupId;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final int totalQuestions;
  final double perQuestionMark;
  final double negativeMark;

  const BattleEntity({
    required this.id,
    required this.title,
    required this.goalId,
    required this.groupId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.perQuestionMark,
    required this.negativeMark,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BattleEntity &&
        other.id == id &&
        other.title == title &&
        other.goalId == goalId &&
        other.groupId == groupId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.durationMinutes == durationMinutes &&
        other.totalQuestions == totalQuestions &&
        other.perQuestionMark == perQuestionMark &&
        other.negativeMark == negativeMark;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        goalId.hashCode ^
        groupId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        durationMinutes.hashCode ^
        totalQuestions.hashCode ^
        perQuestionMark.hashCode ^
        negativeMark.hashCode;
  }
}
