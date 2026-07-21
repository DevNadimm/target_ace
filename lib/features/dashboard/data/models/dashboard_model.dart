class DashboardModel {
  final DashboardExam? activeExam;
  final bool hasSubmittedActiveExam;
  final DashboardStats stats;
  final List<LeaderboardItem> leaderboard;
  final int groupRank;
  final int globalRank;
  final String? lastExamTitle;
  final String? lastExamId;

  DashboardModel({
    this.activeExam,
    this.hasSubmittedActiveExam = false,
    required this.stats,
    required this.leaderboard,
    this.groupRank = 0,
    this.globalRank = 0,
    this.lastExamTitle,
    this.lastExamId,
  });

  factory DashboardModel.empty() {
    return DashboardModel(
      hasSubmittedActiveExam: false,
      stats: DashboardStats(
        totalBattles: 0,
        averageScore: 0.0,
        rank: 0,
        streakCount: 0,
        highestStreak: 0,
      ),
      leaderboard: [],
      lastExamTitle: null,
      lastExamId: null,
    );
  }
}

class DashboardExam {
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

  DashboardExam({
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

  factory DashboardExam.fromJson(Map<String, dynamic> json) {
    return DashboardExam(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Live Mock Exam',
      goalId: json['goal_id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      totalQuestions: json['total_questions'] as int? ?? 30,
      examDate: json['exam_date'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      perQuestionMark: (json['per_question_mark'] as num?)?.toDouble() ?? 1.0,
      negativeMark: (json['negative_mark'] as num?)?.toDouble() ?? 0.25,
    );
  }

  bool get isLive {
    final now = DateTime.now();
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isCompleted => status == 'completed';
  bool get isScheduled => status == 'scheduled';
}

class DashboardStats {
  final int totalBattles;
  final double averageScore;
  final int rank;
  final int totalCorrect;
  final int totalWrong;
  final int streakCount;
  final int highestStreak;

  DashboardStats({
    required this.totalBattles,
    required this.averageScore,
    required this.rank,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.streakCount = 0,
    this.highestStreak = 0,
  });
}

class LeaderboardItem {
  final int rank;
  final String name;
  final double score;
  final String? avatarUrl;
  final bool isCurrentUser;

  LeaderboardItem({
    required this.rank,
    required this.name,
    required this.score,
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}
