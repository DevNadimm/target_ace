class LeaderboardEntryEntity {
  final int rank;
  final String name;
  final String avatarUrl;
  final double score;
  final bool isCurrentUser;

  const LeaderboardEntryEntity({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.isCurrentUser,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntryEntity &&
        other.rank == rank &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.score == score &&
        other.isCurrentUser == isCurrentUser;
  }

  @override
  int get hashCode {
    return rank.hashCode ^
        name.hashCode ^
        avatarUrl.hashCode ^
        score.hashCode ^
        isCurrentUser.hashCode;
  }
}
