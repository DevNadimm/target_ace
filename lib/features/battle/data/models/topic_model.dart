class TopicModel {
  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final int displayOrder;

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    required this.displayOrder,
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
