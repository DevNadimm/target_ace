import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';
import 'package:target_ace/features/practice/data/models/topic_model.dart';

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.groupId,
    required super.name,
    super.description,
    super.imageUrl,
    required super.displayOrder,
    super.totalQuestions = 0,
    super.practicedCount = 0,
    super.topics = const [],
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      practicedCount: json['practiced_count'] as int? ?? 0,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'display_order': displayOrder,
      'total_questions': totalQuestions,
      'practiced_count': practicedCount,
      'topics': topics.map((t) => (t as TopicModel).toJson()).toList(),
    };
  }
}