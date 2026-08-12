import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_arena_data.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

part 'battle_arena_event.dart';
part 'battle_arena_state.dart';

class BattleArenaBloc extends Bloc<BattleArenaEvent, BattleArenaState> {
  final GetBattleArenaData _getBattleArenaData;
  DateTime _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);

  BattleArenaBloc({
    required GetBattleArenaData getBattleArenaData,
  })  : _getBattleArenaData = getBattleArenaData,
        super(BattleArenaInitial()) {
    on<BattleArenaFetchRequested>(_onFetch);
    on<BattleArenaReviewRequested>(_onReviewRequested);
    on<BattleArenaEnterRequested>(_onEnterRequested);
  }

  Future<void> _onFetch(
    BattleArenaFetchRequested event,
    Emitter<BattleArenaState> emit,
  ) async {
    final now = DateTime.now();
    if (!event.force && now.difference(_lastFetchTime).inSeconds < 10) {
      return;
    }
    _lastFetchTime = now;

    if (!event.isSilent) {
      emit(BattleArenaLoading());
    }

    try {
      final goal = await UserLocalDataSource.getUserGoal();
      final groupId = await UserLocalDataSource.getUserGroupId();
      final userId = await UserLocalDataSource.getUserId();

      if (goal.isEmpty) {
        emit(BattleArenaFailure('No active battle group found. Please complete your profile setup.'));
        return;
      }

      String activeGroupId = groupId;
      if (activeGroupId.isEmpty) {
        activeGroupId = await UserLocalDataSource.getUserGroupId();
      }

      if (activeGroupId.isEmpty || userId.isEmpty) {
        emit(BattleArenaFailure('Your profile is not fully configured. Please complete profile setup.'));
        return;
      }

      final result = await _getBattleArenaData(GetBattleArenaDataParams(
        userId: userId,
        groupId: activeGroupId,
      ));

      result.fold(
        (failure) => emit(BattleArenaFailure(failure.message, failure.type)),
        (arenaData) {
          // Build todayExamsList for Hero Card (if active exam exists and not submitted)
          final todayExamsList = <BattleEntity>[];
          if (arenaData.activeExam != null && !arenaData.hasSubmittedActive) {
            todayExamsList.add(arenaData.activeExam!);
          }

          emit(BattleArenaSuccess(
            goalId: goal,
            groupId: activeGroupId,
            todayExams: todayExamsList,
            upcomingExams: arenaData.upcomingExams,
            pastSubmissions: arenaData.recentHistory,
          ));
        },
      );
    } catch (e) {
      emit(BattleArenaFailure(e.toString()));
    }
  }

  Future<void> _onReviewRequested(
    BattleArenaReviewRequested event,
    Emitter<BattleArenaState> emit,
  ) async {
    final currentState = state;
    final status = await UserLocalDataSource.getSubscriptionStatus();
    
    if (status != 'active' && status != 'trial') {
      emit(BattleArenaAccessDenied(status));
    } else {
      emit(BattleArenaReviewAccessGranted(event.examId, event.answers));
    }
    emit(currentState); // Restore UI state
  }

  Future<void> _onEnterRequested(
    BattleArenaEnterRequested event,
    Emitter<BattleArenaState> emit,
  ) async {
    final currentState = state;
    final status = await UserLocalDataSource.getSubscriptionStatus();
    
    if (status != 'active' && status != 'trial') {
      emit(BattleArenaAccessDenied(status));
    } else {
      emit(BattleArenaEnterAccessGranted());
    }
    emit(currentState); // Restore UI state
  }
}