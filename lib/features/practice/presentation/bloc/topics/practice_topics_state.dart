part of 'practice_topics_cubit.dart';

abstract class PracticeTopicsState {}

class PracticeTopicsInitial extends PracticeTopicsState {}

class PracticeTopicsLoading extends PracticeTopicsState {}

class PracticeTopicsLoaded extends PracticeTopicsState {
  final List<TopicEntity> topics;
  PracticeTopicsLoaded(this.topics);
}

class PracticeTopicsError extends PracticeTopicsState {
  final String message;
  PracticeTopicsError(this.message);
}
