import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/practice/domain/entities/question_entity.dart';
import 'package:target_ace/features/battle/domain/usecases/get_user_submissions.dart';
part 'battle_history_event.dart';
part 'battle_history_state.dart';

class BattleHistoryBloc extends Bloc<BattleHistoryEvent, BattleHistoryState> {
  static const int _pageSize = 20;

  final GetUserSubmissions _getUserSubmissions;
  BattleHistoryBloc({
    required GetUserSubmissions getUserSubmissions,
  })  : _getUserSubmissions = getUserSubmissions,
        super(BattleHistoryInitial()) {
    on<FetchBattleHistoryEvent>(_onFetchHistory);
    on<FetchMoreBattleHistoryEvent>(_onFetchMoreHistory);
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

      final result = await _getUserSubmissions(
        GetUserSubmissionsParams(userId: userId, page: 1, limit: _pageSize),
      );
      
      result.fold(
        (failure) => emit(BattleHistoryError(failure.message ?? 'An unknown error occurred.', submissions: state.submissions)),
        (submissions) => emit(BattleHistoryLoaded(
          submissions: submissions,
          currentPage: 1,
          hasMore: submissions.length >= _pageSize,
          isLoadingMore: false,
        )),
      );
    } catch (e) {
      emit(BattleHistoryError(e.toString(), submissions: state.submissions));
    }
  }

  Future<void> _onFetchMoreHistory(
    FetchMoreBattleHistoryEvent event,
    Emitter<BattleHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BattleHistoryLoaded || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final userId = await UserLocalDataSource.getUserId();
      if (userId.isEmpty) {
        emit(currentState.copyWith(isLoadingMore: false));
        return;
      }

      final nextPage = currentState.currentPage + 1;
      final result = await _getUserSubmissions(
        GetUserSubmissionsParams(userId: userId, page: nextPage, limit: _pageSize),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingMore: false)),
        (newSubmissions) {
          final updatedList = List<UserSubmissionEntity>.from(currentState.submissions)..addAll(newSubmissions);
          emit(BattleHistoryLoaded(
            submissions: updatedList,
            currentPage: nextPage,
            hasMore: newSubmissions.length >= _pageSize,
            isLoadingMore: false,
          ));
        },
      );
    } catch (_) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

}
