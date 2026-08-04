import 'package:flutter/foundation.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';

class BattleLeaderboardDataEntity {
  final BattleEntity exam;
  final List<LeaderboardEntryEntity> topSubmissions;
  final LeaderboardEntryEntity? currentUserRecord;

  const BattleLeaderboardDataEntity({
    required this.exam,
    required this.topSubmissions,
    required this.currentUserRecord,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BattleLeaderboardDataEntity &&
        other.exam == exam &&
        listEquals(other.topSubmissions, topSubmissions) &&
        other.currentUserRecord == currentUserRecord;
  }

  @override
  int get hashCode {
    return exam.hashCode ^ Object.hashAll(topSubmissions) ^ currentUserRecord.hashCode;
  }
}
