import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';

class BattleArenaDataEntity {
  final BattleEntity? activeExam;
  final bool hasSubmittedActive;
  final List<BattleEntity> upcomingExams;
  final List<UserSubmissionEntity> recentHistory;

  const BattleArenaDataEntity({
    this.activeExam,
    required this.hasSubmittedActive,
    required this.upcomingExams,
    required this.recentHistory,
  });
}
