class HomeEntity {
  final HomeExamEntity? activeExam;
  final bool hasSubmittedActiveExam;
  final HomeStatsEntity stats;
  final List<LeaderboardItemEntity> leaderboard;
  final int groupRank;
  final int globalRank;
  final String? lastExamTitle;
  final String? lastExamId;
  final LatestPerformanceEntity? latestPerformance;
  final bool isPremium;

  const HomeEntity({
    this.activeExam,
    this.hasSubmittedActiveExam = false,
    required this.stats,
    required this.leaderboard,
    this.groupRank = 0,
    this.globalRank = 0,
    this.lastExamTitle,
    this.lastExamId,
    this.latestPerformance,
    this.isPremium = false,
  });

  factory HomeEntity.empty() {
    return const HomeEntity(
      hasSubmittedActiveExam: false,
      stats: HomeStatsEntity(
        totalBattles: 0,
        averageScore: 0.0,
        rank: 0,
        streakCount: 0,
        highestStreak: 0,
      ),
      leaderboard: [],
      lastExamTitle: null,
      lastExamId: null,
      isPremium: false,
    );
  }
}

class HomeExamEntity {
  final String id;
  final String title;
  final String goalId;
  final String groupId;
  final DateTime startTime;
  final int durationMinutes;
  final int totalQuestions;
  final String? examDate;
  final String status;
  final double perQuestionMark;
  final double negativeMark;

  const HomeExamEntity({
    required this.id,
    required this.title,
    required this.goalId,
    this.groupId = '',
    required this.startTime,
    required this.durationMinutes,
    required this.totalQuestions,
    this.examDate,
    this.status = 'scheduled',
    this.perQuestionMark = 1.0,
    this.negativeMark = 0.25,
  });

  bool get isLive {
    final now = DateTime.now();
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isCompleted => status == 'completed';
  bool get isScheduled => status == 'scheduled';
}

class HomeStatsEntity {
  final int totalBattles;
  final double averageScore;
  final int rank;
  final int totalCorrect;
  final int totalWrong;
  final int streakCount;
  final int highestStreak;
  final List<String> weeklyActiveDays;
  final int unreadNotificationsCount;

  const HomeStatsEntity({
    required this.totalBattles,
    required this.averageScore,
    required this.rank,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.streakCount = 0,
    this.highestStreak = 0,
    this.weeklyActiveDays = const [],
    this.unreadNotificationsCount = 0,
  });
}

class LeaderboardItemEntity {
  final int rank;
  final String name;
  final double score;
  final String? avatarUrl;
  final bool isCurrentUser;

  const LeaderboardItemEntity({
    required this.rank,
    required this.name,
    required this.score,
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}

class LatestPerformanceEntity {
  final String examTitle;
  final DateTime completedAt;
  final int score;
  final int scoreOutOf;
  final double accuracy;
  final int rank;
  final int totalParticipants;
  final Duration timeTaken;
  final bool isLocked;

  const LatestPerformanceEntity({
    required this.examTitle,
    required this.completedAt,
    required this.score,
    required this.scoreOutOf,
    required this.accuracy,
    required this.rank,
    required this.totalParticipants,
    required this.timeTaken,
    this.isLocked = false,
  });
}