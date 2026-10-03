part of 'practice_subjects_cubit.dart';

sealed class PracticeSubjectsState {
  const PracticeSubjectsState();
}

class PracticeSubjectsInitial extends PracticeSubjectsState {
  const PracticeSubjectsInitial();
}

class PracticeSubjectsLoading extends PracticeSubjectsState {
  const PracticeSubjectsLoading();
}

class PracticeSubjectsLoaded extends PracticeSubjectsState {
  final List<SubjectEntity> subjects;
  final bool isRefreshing;
  const PracticeSubjectsLoaded(this.subjects, {this.isRefreshing = false});
}

class PracticeSubjectsFailure extends PracticeSubjectsState {
  final String? error;
  final ErrorType? errorType;
  const PracticeSubjectsFailure([this.error, this.errorType]);
}