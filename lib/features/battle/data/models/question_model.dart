class QuestionModel {
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

  QuestionModel({
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
    this.difficultyLevel = 2,
    this.difficulty = 'medium',
    this.usedCount = 0,
    this.tags = const [],
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((e) => e.toString()).toList();
    }

    return QuestionModel(
      id: json['id'] as String,
      questionText: json['question_text'] as String? ?? '',
      optionA: json['option_a'] as String? ?? '',
      optionB: json['option_b'] as String? ?? '',
      optionC: json['option_c'] as String? ?? '',
      optionD: json['option_d'] as String? ?? '',
      correctOption: json['correct_option'] as String? ?? 'A',
      explanation: json['explanation'] as String?,
      groupId: json['group_id'] as String?,
      subjectId: json['subject_id'] as String?,
      topicId: json['topic_id'] as String?,
      difficultyLevel: json['difficulty_level'] as int? ?? 2,
      difficulty: json['difficulty'] as String? ?? 'medium',
      usedCount: json['used_count'] as int? ?? 0,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
      'explanation': explanation,
      'group_id': groupId,
      'subject_id': subjectId,
      'topic_id': topicId,
      'difficulty_level': difficultyLevel,
      'difficulty': difficulty,
      'used_count': usedCount,
      'tags': tags,
    };
  }
}
