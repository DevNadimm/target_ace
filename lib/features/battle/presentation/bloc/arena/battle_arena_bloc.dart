import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/battle/domain/entities/battle_entity.dart';
import 'package:target_ace/features/battle/domain/entities/user_submission_entity.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_arena_data.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

part 'battle_arena_event.dart';
part 'battle_arena_state.dart';

class BattleArenaBloc extends Bloc<BattleArenaEvent, BattleArenaState> {
  final GetBattleArenaData _getBattleArenaData;

  BattleArenaBloc({
    required GetBattleArenaData getBattleArenaData,
  })  : _getBattleArenaData = getBattleArenaData,
        super(BattleArenaInitial()) {
    on<BattleArenaFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    BattleArenaFetchRequested event,
    Emitter<BattleArenaState> emit,
  ) async {
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
        (failure) => emit(BattleArenaFailure(failure.message)),
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
}
