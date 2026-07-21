import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/battle/data/repos/battle_repo.dart';

part 'live_battle_hub_event.dart';
part 'live_battle_hub_state.dart';

class LiveBattleHubBloc extends Bloc<LiveBattleHubEvent, LiveBattleHubState> {
  LiveBattleHubBloc() : super(LiveBattleHubInitial()) {
    on<LiveBattleHubFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    LiveBattleHubFetchRequested event,
    Emitter<LiveBattleHubState> emit,
  ) async {
    if (!event.isSilent) {
      emit(LiveBattleHubLoading());
    }

    try {
      final goal = await AppPreferences.getUserGoal();
      final groupId = await AppPreferences.getActiveGroupId();
      final userId = await AppPreferences.getUserId();

      final activeGoalId = goal.isEmpty ? 'bcs' : goal;
      String activeGroupId = groupId;
      if (activeGroupId.isEmpty) {
        activeGroupId = await AppPreferences.getUserGroup();
      }

      // Parallel fetch using Repository
      final results = await Future.wait([
        BattleRepo.getGroupExams(activeGroupId),
        BattleRepo.getUserSubmissions(userId),
      ]);

      final exams = List<Map<String, dynamic>>.from(results[0]);
      final submissions = List<Map<String, dynamic>>.from(results[1]);

      final now = DateTime.now();
      final todayExamsList = <Map<String, dynamic>>[];
      final upcomingExamsList = <Map<String, dynamic>>[];

      for (final exam in exams) {
        final startTimeStr = exam['start_time'] as String?;
        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr).toLocal();
          final durationMins = (exam['duration_minutes'] as int?) ?? 30;
          final endTime = startTime.add(Duration(minutes: durationMins));

          if (now.isBefore(endTime)) {
            if (startTime.day == now.day && startTime.month == now.month) {
              todayExamsList.add(exam);
            } else if (startTime.isAfter(now)) {
              upcomingExamsList.add(exam);
            }
          }
        }
      }

      emit(LiveBattleHubSuccess(
        goalId: activeGoalId,
        groupId: activeGroupId,
        todayExams: todayExamsList,
        upcomingExams: upcomingExamsList,
        pastSubmissions: submissions,
      ));
    } catch (e) {
      emit(LiveBattleHubFailure(e.toString()));
    }
  }
}
