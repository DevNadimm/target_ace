import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/services/notification_service.dart';
import 'package:target_ace/core/utils/helpers/date_formatter.dart';
import 'package:target_ace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';

import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';

// -- State ------------------------------------------------------------------

enum GroupSwitchStatus { loading, locked, unlocked, saving, success, error }

class GroupSwitchState {
  final GroupSwitchStatus status;
  final String currentGroupTitle;
  final String lockExpiryDate;
  final int remainingDays;
  final int currentStep; // 0 = goal, 1 = group
  final String selectedGoal;
  final String selectedGroup;
  final List<OnboardingGoalEntity> goals;
  final List<BattleGroupEntity> groups;
  final bool isFetchingGroups;
  final String? errorMessage;

  const GroupSwitchState({
    this.status = GroupSwitchStatus.loading,
    this.currentGroupTitle = '',
    this.lockExpiryDate = '',
    this.remainingDays = 0,
    this.currentStep = 0,
    this.selectedGoal = '',
    this.selectedGroup = '',
    this.goals = const [],
    this.groups = const [],
    this.isFetchingGroups = false,
    this.errorMessage,
  });

  bool get requiresGroupSelection => groups.isNotEmpty;

  GroupSwitchState copyWith({
    GroupSwitchStatus? status,
    String? currentGroupTitle,
    String? lockExpiryDate,
    int? remainingDays,
    int? currentStep,
    String? selectedGoal,
    String? selectedGroup,
    List<OnboardingGoalEntity>? goals,
    List<BattleGroupEntity>? groups,
    bool? isFetchingGroups,
    String? errorMessage,
  }) {
    return GroupSwitchState(
      status: status ?? this.status,
      currentGroupTitle: currentGroupTitle ?? this.currentGroupTitle,
      lockExpiryDate: lockExpiryDate ?? this.lockExpiryDate,
      remainingDays: remainingDays ?? this.remainingDays,
      currentStep: currentStep ?? this.currentStep,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      goals: goals ?? this.goals,
      groups: groups ?? this.groups,
      isFetchingGroups: isFetchingGroups ?? this.isFetchingGroups,
      errorMessage: errorMessage, // raw update
    );
  }
}

// -- Cubit ------------------------------------------------------------------

class GroupSwitchCubit extends Cubit<GroupSwitchState> {
  final NotificationService _notificationService;
  final ProfileRepository _profileRepository;
  final AuthRemoteDataSource _authRemoteDataSource;

  GroupSwitchCubit({
    required NotificationService notificationService,
    required ProfileRepository profileRepository,
    required AuthRemoteDataSource authRemoteDataSource,
  })  : _notificationService = notificationService,
        _profileRepository = profileRepository,
        _authRemoteDataSource = authRemoteDataSource,
        super(const GroupSwitchState());

  /// Check if the user is currently locked into their current group.
  Future<void> checkLockStatus() async {
    emit(state.copyWith(status: GroupSwitchStatus.loading));

    try {
      final lockedUntilStr = await UserLocalDataSource.getUserGroupLockedUntil();
      final currentGroup = await UserLocalDataSource.getUserGroupTitle();

      if (lockedUntilStr != null && lockedUntilStr.isNotEmpty) {
        final lockedUntil = DateTime.tryParse(lockedUntilStr);
        if (lockedUntil == null) {
          emit(state.copyWith(status: GroupSwitchStatus.unlocked));
          return;
        }

        final now = DateTime.now();
        if (now.isAfter(lockedUntil)) {
          // Lock expired
          emit(state.copyWith(status: GroupSwitchStatus.unlocked));
          return;
        }

        // Still locked
        final remaining = lockedUntil.difference(now).inDays + 1;
        var expiryFormatted = '';
        try {
          expiryFormatted = DateFormatter.readable(lockedUntilStr);
        } catch (_) {
          expiryFormatted = DateFormatter.readable(lockedUntil);
        }

        emit(state.copyWith(
          status: GroupSwitchStatus.locked,
          currentGroupTitle: (currentGroup != null && currentGroup.isNotEmpty) ? currentGroup : 'Your Current Group',
          lockExpiryDate: expiryFormatted,
          remainingDays: remaining,
        ));
      } else {
        final res = await _profileRepository.getOnboardingGoals();
        
        res.fold(
          (failure) => throw Exception(failure.message),
          (goals) => emit(state.copyWith(
            status: GroupSwitchStatus.unlocked,
            goals: goals,
          )),
        );
      }
    } catch (e) {
      emit(state.copyWith(
        status: GroupSwitchStatus.error,
        errorMessage: 'Failed to check lock status: $e',
      ));
    }
  }

  /// Select a goal in step 0.
  void selectGoal(String goalId) {
    emit(state.copyWith(selectedGoal: goalId, selectedGroup: ''));
  }

  /// Select a group in step 1.
  void selectGroup(String groupId) {
    emit(state.copyWith(selectedGroup: groupId));
  }

  /// Advance to the next step or trigger submission.
  /// Returns true if submission should be confirmed (show dialog).
  Future<bool> nextStep() async {
    if (state.currentStep == 0) {
      if (state.selectedGoal.isEmpty) return false;

      // Use preloaded nested battleGroups from memory if present
      final matchingGoal = state.goals.where((g) => g.id == state.selectedGoal);
      final preloadedGroups = matchingGoal.isNotEmpty ? matchingGoal.first.battleGroups : <BattleGroupEntity>[];

      if (preloadedGroups.isNotEmpty) {
        emit(state.copyWith(
          currentStep: 1,
          groups: preloadedGroups,
          isFetchingGroups: false,
        ));
        return false;
      }

      // Fetch groups for the selected goal if preloaded is empty
      emit(state.copyWith(isFetchingGroups: true, groups: []));

      try {
        final res = await _profileRepository.getBattleGroups(state.selectedGoal);

        return res.fold(
          (failure) {
            emit(state.copyWith(
              isFetchingGroups: false,
              errorMessage: failure.message,
            ));
            return false;
          },
          (groups) {
            if (groups.isNotEmpty) {
              emit(state.copyWith(
                currentStep: 1,
                groups: groups,
                isFetchingGroups: false,
              ));
              return false; // Need group selection next
            } else {
              // No subgroups -- selectedGroup = selectedGoal
              emit(state.copyWith(
                selectedGroup: state.selectedGoal,
                isFetchingGroups: false,
              ));
              return true; // Ready for confirmation
            }
          },
        );
      } catch (e) {
        emit(state.copyWith(
          isFetchingGroups: false,
          errorMessage: 'Failed to load groups: $e',
        ));
        return false;
      }
    } else {
      // Step 1 -- group already selected
      if (state.selectedGroup.isEmpty) return false;
      return true; // Ready for confirmation
    }
  }

  /// Go back one step.
  void previousStep() {
    if (state.currentStep == 1) {
      emit(state.copyWith(currentStep: 0));
    }
  }

  /// Returns the title of the group being switched to (for confirmation dialog).
  String get newGroupTitle {
    if (state.requiresGroupSelection) {
      final matches = state.groups.where((g) => g.id == state.selectedGroup);
      return matches.isNotEmpty ? matches.first.title : 'General';
    } else {
      final matches = state.goals.where((g) => g.id == state.selectedGoal);
      return matches.isNotEmpty ? matches.first.title : 'General';
    }
  }

  /// Submit the group switch.
  Future<void> submitGroupSwitch() async {
    final authUser = _authRemoteDataSource.currentUser;
    if (authUser == null) return;

    emit(state.copyWith(status: GroupSwitchStatus.saving));

    try {
      final oldGroupId = await UserLocalDataSource.getUserGroupId();
      final groupTitle = newGroupTitle;

      final res = await _profileRepository.switchGroup(
        userId: authUser.id,
        goalId: state.selectedGoal,
        groupId: state.selectedGroup,
      );

      await res.fold(
        (failure) async {
          emit(state.copyWith(
            status: GroupSwitchStatus.unlocked,
            errorMessage: failure.message,
          ));
        },
        (lockedUntil) async {
          await UserLocalDataSource.updateFields({
            'goal': state.selectedGoal,
            'group_id': state.selectedGroup,
            'group_title': groupTitle,
            'group_locked_until': lockedUntil,
          });

          await _notificationService.updateGroupSubscription(oldGroupId, state.selectedGroup);
          emit(state.copyWith(status: GroupSwitchStatus.success));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: GroupSwitchStatus.unlocked,
        errorMessage: 'Failed to switch group: $e',
      ));
    }
  }
}