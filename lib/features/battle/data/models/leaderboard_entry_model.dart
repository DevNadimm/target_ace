import 'package:target_ace/features/battle/domain/entities/leaderboard_entry_entity.dart';

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.rank,
    required super.name,
    required super.avatarUrl,
    required super.score,
    required super.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    String? name = json['name'] as String?;
    String? avatarUrl = json['avatar_url'] as String?;

    if ((name == null || name.trim().isEmpty) && json['profiles'] != null) {
      final profiles = json['profiles'];
      if (profiles is Map<String, dynamic>) {
        name = profiles['name'] as String?;
        avatarUrl ??= profiles['avatar_url'] as String?;
      } else if (profiles is Map) {
        name = profiles['name']?.toString();
        avatarUrl ??= profiles['avatar_url']?.toString();
      } else if (profiles is List && profiles.isNotEmpty) {
        final first = profiles[0];
        if (first is Map) {
          name = first['name']?.toString();
          avatarUrl ??= first['avatar_url']?.toString();
        }
      }
    }

    return LeaderboardEntryModel(
      rank: json['rank'] as int? ?? 0,
      name: (name != null && name.trim().isNotEmpty) ? name : 'Student',
      avatarUrl: avatarUrl ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'name': name,
      'avatar_url': avatarUrl,
      'score': score,
      'is_current_user': isCurrentUser,
    };
  }
}
