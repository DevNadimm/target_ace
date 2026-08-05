import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/home/domain/entities/home_entity.dart';
import 'package:target_ace/features/home/domain/usecases/get_home.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHome getHome;

  HomeBloc({
    required this.getHome,
  }) : super(HomeInitial()) {
    on<HomeFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    HomeFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (!event.isSilent) {
      emit(HomeLoading());
    }

    final result = await getHome(const NoParams());

    result.fold(
      (failure) {
        if (!event.isSilent) {
          emit(HomeFailure(ErrorType.unknown, failure.message));
        }
      },
      (homeEntity) {
        emit(HomeSuccess(homeEntity));
      },
    );
  }
}