part of 'practice_session_cubit.dart';

enum PracticeSessionStatus { initial, loading, loaded, failure }

class PracticeSessionState {
  final PracticeSessionStatus status;
  final List<TopicEntity> topics;
  final List<QuestionEntity> questions;
  final int currentIndex;
  final String? selectedOption;
  final String? selectedTopicId;
  final Set<String> bookmarkedIds;
  final Map<String, bool> previousAttempts;
  final String? errorMessage;

  const PracticeSessionState({
    this.status = PracticeSessionStatus.initial,
    this.topics = const [],
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedOption,
    this.selectedTopicId,
    this.bookmarkedIds = const {},
    this.previousAttempts = const {},
    this.errorMessage,
  });

  bool isBookmarked(String questionId) => bookmarkedIds.contains(questionId);

  QuestionEntity? get currentQuestion =>
      currentIndex >= 0 && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  PracticeSessionState copyWith({
    PracticeSessionStatus? status,
    List<TopicEntity>? topics,
    List<QuestionEntity>? questions,
    int? currentIndex,
    String? selectedOption,
    String? selectedTopicId,
    Set<String>? bookmarkedIds,
    Map<String, bool>? previousAttempts,
    String? errorMessage,
  }) {
    return PracticeSessionState(
      status: status ?? this.status,
      topics: topics ?? this.topics,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: selectedOption,
      selectedTopicId: selectedTopicId,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      previousAttempts: previousAttempts ?? this.previousAttempts,
      errorMessage: errorMessage,
    );
  }
}