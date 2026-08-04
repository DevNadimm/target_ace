import 'package:target_ace/features/dashboard/domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    super.activeExam,
    super.hasSubmittedActiveExam = false,
    required super.stats,
    required super.leaderboard,
    super.groupRank = 0,
    super.globalRank = 0,
    super.lastExamTitle,
    super.lastExamId,
    super.latestPerformance,
    super.isPremium = false,
  });

  factory DashboardModel.empty() {
    return const DashboardModel(
      hasSubmittedActiveExam: false,
      stats: DashboardStatsModel(
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

class DashboardExamModel extends DashboardExamEntity {
  const DashboardExamModel({
    required super.id,
    required super.title,
    required super.goalId,
    super.groupId = '',
    required super.startTime,
    required super.durationMinutes,
    required super.totalQuestions,
    super.examDate,
    super.status = 'scheduled',
    super.perQuestionMark = 1.0,
    super.negativeMark = 0.25,
  });

  factory DashboardExamModel.fromJson(Map<String, dynamic> json) {
    return DashboardExamModel(
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
}

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalBattles,
    required super.averageScore,
    required super.rank,
    super.totalCorrect = 0,
    super.totalWrong = 0,
    super.streakCount = 0,
    super.highestStreak = 0,
    super.weeklyActiveDays = const [],
    super.unreadNotificationsCount = 0,
  });
}

class LeaderboardItemModel extends LeaderboardItemEntity {
  const LeaderboardItemModel({
    required super.rank,
    required super.name,
    required super.score,
    super.avatarUrl,
    super.isCurrentUser = false,
  });
}

class LatestPerformanceModel extends LatestPerformanceEntity {
  const LatestPerformanceModel({
    required super.examTitle,
    required super.completedAt,
    required super.score,
    required super.scoreOutOf,
    required super.accuracy,
    required super.rank,
    required super.totalParticipants,
    required super.timeTaken,
  });
}
