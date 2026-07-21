class SubjectModel {
  final String id;
  final String goalId;
  final String? groupId;
  final String name;
  final String? description;
  final String iconName;
  final int displayOrder;

  SubjectModel({
    required this.id,
    required this.goalId,
    this.groupId,
    required this.name,
    this.description,
    this.iconName = 'book',
    required this.displayOrder,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      groupId: json['group_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String? ?? 'book',
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
      'icon_name': iconName,
      'display_order': displayOrder,
    };
  }
}
