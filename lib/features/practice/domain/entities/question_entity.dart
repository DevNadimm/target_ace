class QuestionEntity {
  final String id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String? explanation;
  final String? groupId;
  final String? subjectId;
  final String? topicId;
  final int difficultyLevel;
  final String difficulty;
  final int usedCount;
  final List<String> tags;

  const QuestionEntity({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.explanation,
    this.groupId,
    this.subjectId,
    this.topicId,
    required this.difficultyLevel,
    required this.difficulty,
    required this.usedCount,
    required this.tags,
  });
}