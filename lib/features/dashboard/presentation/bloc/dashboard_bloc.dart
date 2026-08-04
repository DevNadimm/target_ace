import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:target_ace/features/dashboard/domain/usecases/get_dashboard.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboard getDashboard;

  DashboardBloc({
    required this.getDashboard,
  }) : super(DashboardInitial()) {
    on<DashboardFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    DashboardFetchRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!event.isSilent) {
      emit(DashboardLoading());
    }

    final result = await getDashboard(const NoParams());

    result.fold(
      (failure) {
        if (!event.isSilent) {
          emit(DashboardFailure(ErrorType.unknown, failure.message));
        }
      },
      (dashboardEntity) {
        emit(DashboardSuccess(dashboardEntity));
      },
    );
  }
}
