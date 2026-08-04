part of 'bookmarked_questions_cubit.dart';

abstract class BookmarkedQuestionsState {
  const BookmarkedQuestionsState();
}

class BookmarkedQuestionsInitial extends BookmarkedQuestionsState {}

class BookmarkedQuestionsLoading extends BookmarkedQuestionsState {}

class BookmarkedQuestionsLoaded extends BookmarkedQuestionsState {
  final List<QuestionEntity> questions;
  final int currentIndex;
  final String? selectedOption;

  const BookmarkedQuestionsLoaded({
    required this.questions,
    this.currentIndex = 0,
    this.selectedOption,
  });

  BookmarkedQuestionsLoaded copyWith({
    List<QuestionEntity>? questions,
    int? currentIndex,
    String? selectedOption,
  }) {
    return BookmarkedQuestionsLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption: selectedOption,
    );
  }
}

class BookmarkedQuestionsError extends BookmarkedQuestionsState {
  final String message;
  const BookmarkedQuestionsError(this.message);
}
