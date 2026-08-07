import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/battle/domain/usecases/get_user_submissions.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_questions.dart';

part 'battle_history_event.dart';
part 'battle_history_state.dart';

class BattleHistoryBloc extends Bloc<BattleHistoryEvent, BattleHistoryState> {
  final GetUserSubmissions _getUserSubmissions;
  final GetBattleQuestions _getBattleQuestions;

  BattleHistoryBloc({
    required GetUserSubmissions getUserSubmissions,
    required GetBattleQuestions getBattleQuestions,
  })  : _getUserSubmissions = getUserSubmissions,
        _getBattleQuestions = getBattleQuestions,
        super(BattleHistoryInitial()) {
    on<FetchBattleHistoryEvent>(_onFetchHistory);
    on<FetchBattleQuestionsEvent>(_onFetchQuestions);
  }

  Future<void> _onFetchHistory(
    FetchBattleHistoryEvent event,
    Emitter<BattleHistoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(BattleHistoryLoading(submissions: state.submissions));
    }

    try {
      final userId = await UserLocalDataSource.getUserId();
      if (userId.isEmpty) {
        emit(BattleHistoryError('User ID not found.', submissions: state.submissions));
        return;
      }

      final result = await _getUserSubmissions(userId);
      result.fold(
        (failure) => emit(BattleHistoryError(failure.message ?? 'An unknown error occurred.', submissions: state.submissions)),
        (submissions) => emit(BattleHistoryLoaded(submissions: submissions)),
      );
    } catch (e) {
      emit(BattleHistoryError(e.toString(), submissions: state.submissions));
    }
  }

  Future<void> _onFetchQuestions(
    FetchBattleQuestionsEvent event,
    Emitter<BattleHistoryState> emit,
  ) async {
    emit(BattleHistoryReviewLoading(submissions: state.submissions));

    try {
      final result = await _getBattleQuestions(event.examId);
      result.fold(
        (failure) => emit(BattleHistoryReviewError(failure.message ?? 'An unknown error occurred.', submissions: state.submissions)),
        (questions) => emit(BattleHistoryReviewReady(
          questions: questions,
          userAnswers: event.userAnswers,
          submissions: state.submissions,
        )),
      );
    } catch (e) {
      emit(BattleHistoryReviewError(e.toString(), submissions: state.submissions));
    }
  }
}
