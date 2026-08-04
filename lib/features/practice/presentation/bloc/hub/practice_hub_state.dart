part of 'practice_hub_cubit.dart';

abstract class PracticeHubState {
  const PracticeHubState();
}

class PracticeHubInitial extends PracticeHubState {}

class PracticeHubLoading extends PracticeHubState {}

class PracticeHubLoaded extends PracticeHubState {
  final int totalAttempted;
  final int totalCorrect;
  final double accuracyRate;
  final int todayCount;
  final String? lastSubjectId;
  final String? lastSubjectName;
  final List<dynamic> subjectProgress;
  final bool isRefreshing;

  const PracticeHubLoaded({
    required this.totalAttempted,
    required this.totalCorrect,
    required this.accuracyRate,
    required this.todayCount,
    required this.subjectProgress,
    this.lastSubjectId,
    this.lastSubjectName,
    this.isRefreshing = false,
  });

  PracticeHubLoaded copyWith({
    int? totalAttempted,
    int? totalCorrect,
    double? accuracyRate,
    int? todayCount,
    String? lastSubjectId,
    String? lastSubjectName,
    List<dynamic>? subjectProgress,
    bool? isRefreshing,
  }) {
    return PracticeHubLoaded(
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

class PracticeHubError extends PracticeHubState {
  final String message;
  const PracticeHubError(this.message);
}
