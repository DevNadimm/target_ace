import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  QuestionModel({
    required super.id,
    required super.questionText,
    required super.optionA,
    required super.optionB,
    required super.optionC,
    required super.optionD,
    required super.correctOption,
    super.explanation,
    super.groupId,
    super.subjectId,
    super.topicId,
    super.difficultyLevel = 2,
    super.difficulty = 'medium',
    super.usedCount = 0,
    super.tags = const [],
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
