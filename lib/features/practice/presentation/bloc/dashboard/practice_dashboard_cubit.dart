import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';

part 'practice_dashboard_state.dart';

class PracticeDashboardCubit extends Cubit<PracticeDashboardState> {
  final PracticeRepository _repository;

  PracticeDashboardCubit({required PracticeRepository repository})
      : _repository = repository,
        super(PracticeDashboardInitial());

  Future<void> loadDashboardData({bool force = false, bool isSilent = false}) async {
    if (state is PracticeDashboardLoaded) {
      if (!force) return;
      emit((state as PracticeDashboardLoaded).copyWith(isRefreshing: true));
    } else {
      if (!isSilent) emit(PracticeDashboardLoading());
    }
    try {
      if (force) {
        // Wait briefly to allow any background syncs (like practice attempts) to complete
        // before fetching the new summary. This also guarantees the syncing animation is visible.
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final userGoal = await UserLocalDataSource.getUserGoal();
      
      if (userGoal.isEmpty) {
        emit(const PracticeDashboardError("No goal selected. Please select a goal first."));
        return;
      }

      final res = await _repository.getPracticeDashboardData(userGoal.toLowerCase());

      res.fold(
        (failure) => emit(PracticeDashboardError(failure.message, failure.type)),
        (data) {
          final attempted = (data['total_attempted'] as num?)?.toInt() ?? 0;
          final correct = (data['total_correct'] as num?)?.toInt() ?? 0;
          final accuracy = (data['accuracy_rate'] as num?)?.toDouble() ?? 0.0;
          final today = (data['today_count'] as num?)?.toInt() ?? 0;
          final lastSubId = data['last_subject_id'] as String?;
          final lastSubName = data['last_subject_name'] as String?;
          final subjectProgress = data['subject_progress'] as List<dynamic>? ?? [];

          emit(PracticeDashboardLoaded(
            totalAttempted: attempted,
            totalCorrect: correct,
            accuracyRate: accuracy,
            todayCount: today,
            subjectProgress: subjectProgress,
            lastSubjectId: lastSubId,
            lastSubjectName: lastSubName,
          ));
        },
      );
    } catch (e) {
      emit(PracticeDashboardError(e.toString()));
    }
  }
}