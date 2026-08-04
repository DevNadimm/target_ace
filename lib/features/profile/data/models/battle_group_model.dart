import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';

class BattleGroupModel extends BattleGroupEntity {
  const BattleGroupModel({
    required super.id,
    required super.goalId,
    required super.title,
    required super.subtitle,
    required super.iconName,
  });

  factory BattleGroupModel.fromJson(Map<String, dynamic> json) {
    return BattleGroupModel(
      id: json['id']?.toString() ?? '',
      goalId: json['goal_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString() ?? '',
      iconName: json['icon_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'subtitle': subtitle,
      'icon_name': iconName,
    };
  }
}
