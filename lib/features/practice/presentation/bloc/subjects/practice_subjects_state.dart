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
  const PracticeSubjectsLoaded(this.subjects);
}

class PracticeSubjectsFailure extends PracticeSubjectsState {
  final String error;
  const PracticeSubjectsFailure(this.error);
}