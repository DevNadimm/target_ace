import 'package:target_ace/features/practice/domain/entities/topic_entity.dart';

class TopicModel extends TopicEntity {
  TopicModel({
    required super.id,
    required super.subjectId,
    required super.name,
    super.description,
    required super.displayOrder,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'description': description,
      'display_order': displayOrder,
    };
  }
}
