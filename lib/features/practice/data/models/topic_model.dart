import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';

class TopicModel extends TopicEntity {
  TopicModel({
    required super.id,
    required super.subjectId,
    required super.name,
    super.description,
    super.imageUrl,
    required super.displayOrder,
    super.totalQuestions = 0,
    super.practicedCount = 0,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      practicedCount: json['practiced_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'total_questions': totalQuestions,
      'practiced_count': practicedCount,
    };
  }
}