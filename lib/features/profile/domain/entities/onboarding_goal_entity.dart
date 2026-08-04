import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';

class OnboardingGoalEntity {
  final String id;
  final String title;
  final String subtitle;
  final String colorHex;
  final String iconName;
  final List<BattleGroupEntity> battleGroups;

  const OnboardingGoalEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorHex,
    required this.iconName,
    this.battleGroups = const [],
  });
}
