import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';

part 'bookmarked_questions_state.dart';

class BookmarkedQuestionsCubit extends Cubit<BookmarkedQuestionsState> {
  final PracticeRepository _repository;

  BookmarkedQuestionsCubit({required PracticeRepository repository})
      : _repository = repository,
        super(BookmarkedQuestionsInitial());

  Future<void> loadBookmarks() async {
    emit(BookmarkedQuestionsLoading());
    final res = await _repository.getBookmarkedQuestions();
    res.fold(
      (failure) => emit(BookmarkedQuestionsError(failure.message)),
      (questions) => emit(BookmarkedQuestionsLoaded(questions: questions)),
    );
  }

  void selectOption(String option) {
    if (state is! BookmarkedQuestionsLoaded) return;
    final currentState = state as BookmarkedQuestionsLoaded;
    if (currentState.selectedOption != null) return;

    emit(currentState.copyWith(selectedOption: option));

    final q = currentState.questions[currentState.currentIndex];
    final isCorrect = option.toUpperCase() == q.correctOption.toUpperCase();
    _repository.recordAttempts([{
      'question_id': q.id,
      'subject_id': q.subjectId,
      'topic_id': q.topicId,
      'selected_option': option,
      'is_correct': isCorrect,
    }]);
  }

  Future<void> removeBookmark(String questionId) async {
    if (state is! BookmarkedQuestionsLoaded) return;
    final currentState = state as BookmarkedQuestionsLoaded;

    await _repository.toggleBookmark(questionId);
    final updatedList = currentState.questions.where((q) => q.id != questionId).toList();
    int newIndex = currentState.currentIndex;
    if (newIndex >= updatedList.length && updatedList.isNotEmpty) {
      newIndex = updatedList.length - 1;
    }

    emit(BookmarkedQuestionsLoaded(
      questions: updatedList,
      currentIndex: newIndex,
      selectedOption: null,
    ));
  }

  void nextQuestion() {
    if (state is! BookmarkedQuestionsLoaded) return;
    final currentState = state as BookmarkedQuestionsLoaded;
    if (currentState.currentIndex < currentState.questions.length - 1) {
      emit(currentState.copyWith(
        currentIndex: currentState.currentIndex + 1,
        selectedOption: null,
      ));
    }
  }

  void previousQuestion() {
    if (state is! BookmarkedQuestionsLoaded) return;
    final currentState = state as BookmarkedQuestionsLoaded;
    if (currentState.currentIndex > 0) {
      emit(currentState.copyWith(
        currentIndex: currentState.currentIndex - 1,
        selectedOption: null,
      ));
    }
  }
}
