import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_questions.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';

part 'battle_review_event.dart';
part 'battle_review_state.dart';

class BattleReviewBloc extends Bloc<BattleReviewEvent, BattleReviewState> {
  static const int _pageSize = 10;

  final GetBattleQuestions _getBattleQuestions;

  BattleReviewBloc(this._getBattleQuestions) : super(BattleReviewState()) {
    on<FetchReviewQuestionsEvent>(_onFetchReviewQuestions);
    on<FetchMoreReviewQuestionsEvent>(
      _onFetchMoreReviewQuestions,
      transformer: droppable(),
    );
  }

  Future<void> _onFetchReviewQuestions(
    FetchReviewQuestionsEvent event,
    Emitter<BattleReviewState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      questions: [],
      currentPage: 1,
      hasMore: true,
      errorMessage: null,
    ));

    final result = await _getBattleQuestions(
      GetBattleQuestionsParams(
        examId: event.examId,
        page: 1,
        limit: _pageSize,
        fetchAll: false,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (questions) => emit(state.copyWith(
        isLoading: false,
        questions: questions,
        hasMore: questions.length == _pageSize,
        currentPage: 2,
      )),
    );
  }

  Future<void> _onFetchMoreReviewQuestions(
    FetchMoreReviewQuestionsEvent event,
    Emitter<BattleReviewState> emit,
  ) async {
    if (!state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final result = await _getBattleQuestions(
      GetBattleQuestionsParams(
        examId: event.examId,
        page: state.currentPage,
        limit: _pageSize,
        fetchAll: false,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      )),
      (questions) {
        final newQuestions = List<QuestionEntity>.from(state.questions)..addAll(questions);
        emit(state.copyWith(
          isLoadingMore: false,
          questions: newQuestions,
          hasMore: questions.length == _pageSize,
          currentPage: state.currentPage + 1,
        ));
      },
    );
  }
}
