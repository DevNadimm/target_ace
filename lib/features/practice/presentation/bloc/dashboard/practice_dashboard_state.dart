part of 'practice_dashboard_cubit.dart';

abstract class PracticeDashboardState {
  const PracticeDashboardState();
}

class PracticeDashboardInitial extends PracticeDashboardState {}

class PracticeDashboardLoading extends PracticeDashboardState {}

class PracticeDashboardLoaded extends PracticeDashboardState {
  final int totalAttempted;
  final int totalCorrect;
  final double accuracyRate;
  final int todayCount;
  final String? lastSubjectId;
  final String? lastSubjectName;
  final List<dynamic> subjectProgress;
  final bool isRefreshing;

  const PracticeDashboardLoaded({
    required this.totalAttempted,
    required this.totalCorrect,
    required this.accuracyRate,
    required this.todayCount,
    required this.subjectProgress,
    this.lastSubjectId,
    this.lastSubjectName,
    this.isRefreshing = false,
  });

  PracticeDashboardLoaded copyWith({
    int? totalAttempted,
    int? totalCorrect,
    double? accuracyRate,
    int? todayCount,
    String? lastSubjectId,
    String? lastSubjectName,
    List<dynamic>? subjectProgress,
    bool? isRefreshing,
  }) {
    return PracticeDashboardLoaded(
      totalAttempted: totalAttempted ?? this.totalAttempted,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      todayCount: todayCount ?? this.todayCount,
      lastSubjectId: lastSubjectId ?? this.lastSubjectId,
      lastSubjectName: lastSubjectName ?? this.lastSubjectName,
      subjectProgress: subjectProgress ?? this.subjectProgress,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class PracticeDashboardError extends PracticeDashboardState {
  final String? message;
  final ErrorType? errorType;
  const PracticeDashboardError([this.message, this.errorType]);
}