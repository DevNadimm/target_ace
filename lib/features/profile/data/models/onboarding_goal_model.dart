import 'package:target_ace/features/profile/data/models/battle_group_model.dart';
import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';

class OnboardingGoalModel extends OnboardingGoalEntity {
  const OnboardingGoalModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.colorHex,
    required super.iconName,
    super.battleGroups = const [],
  });

  factory OnboardingGoalModel.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['battle_groups'] as List<dynamic>? ?? [];
    final groups = rawGroups
        .map((e) => BattleGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OnboardingGoalModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      colorHex: json['color_hex']?.toString() ?? '#3B82F6',
      iconName: json['icon_name']?.toString() ?? '',
      battleGroups: groups,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'color_hex': colorHex,
      'icon_name': iconName,
      'battle_groups': battleGroups,
    };
  }
}
