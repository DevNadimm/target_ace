import 'package:target_ace/features/practice/domain/entities/subject_entity.dart';

class SubjectModel extends SubjectEntity {
  SubjectModel({
    required super.id,
    required super.goalId,
    super.groupId,
    required super.name,
    super.description,
    super.imageUrl,
    required super.displayOrder,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      groupId: json['group_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'group_id': groupId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'display_order': displayOrder,
    };
  }
}
