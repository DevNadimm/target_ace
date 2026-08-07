import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/features/home/domain/usecases/get_group_leaderboard.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final GetGroupLeaderboard getGroupLeaderboard;

  LeaderboardCubit({
    required this.getGroupLeaderboard,
  }) : super(LeaderboardInitial());

  Future<void> fetchLeaderboard(String groupId) async {
    emit(LeaderboardLoading());
    final result = await getGroupLeaderboard(groupId);

    result.fold(
      (failure) => emit(LeaderboardFailure(failure.message, failure.type)),
      (data) => emit(LeaderboardSuccess(data)),
    );
  }
}