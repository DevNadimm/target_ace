import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/dashboard/data/models/dashboard_model.dart';
import 'package:target_ace/features/dashboard/data/repos/dashboard_repo.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    DashboardFetchRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!event.isSilent) {
      emit(DashboardLoading());
    }
    try {
      final result = await DashboardRepo.getDashboard();
      emit(DashboardSuccess(result));
    } catch (e) {
      if (!event.isSilent) {
        emit(DashboardFailure(ErrorType.unknown, e.toString()));
      }
    }
  }
}

