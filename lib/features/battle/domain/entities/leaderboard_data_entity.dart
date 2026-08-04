import 'package:flutter/foundation.dart';
import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';

class LeaderboardDataEntity {
  final int examRank;
  final int groupRank;
  final int globalRank;
  final List<LeaderboardEntryEntity> leaderboard;

  const LeaderboardDataEntity({
    required this.examRank,
    required this.groupRank,
    required this.globalRank,
    required this.leaderboard,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardDataEntity &&
        other.examRank == examRank &&
        other.groupRank == groupRank &&
        other.globalRank == globalRank &&
        listEquals(other.leaderboard, leaderboard);
  }

  @override
  int get hashCode {
    return examRank.hashCode ^
        groupRank.hashCode ^
        globalRank.hashCode ^
        Object.hashAll(leaderboard);
  }
}
