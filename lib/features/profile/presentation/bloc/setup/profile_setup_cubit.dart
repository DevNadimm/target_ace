import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/usecases/do_setup_profile.dart';
import 'package:target_ace/features/profile/domain/entities/onboarding_goal_entity.dart';
import 'package:target_ace/features/profile/domain/entities/battle_group_entity.dart';
import 'package:target_ace/features/profile/domain/usecases/get_battle_groups.dart';
import 'package:target_ace/features/profile/domain/usecases/get_onboarding_goals.dart';
import 'package:target_ace/features/profile/domain/usecases/check_phone_unique.dart';

part 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final GetOnboardingGoals _getOnboardingGoals;
  final GetBattleGroups _getBattleGroups;
  final DoSetupProfile _doSetupProfile;
  final CheckPhoneUnique _checkPhoneUnique;

  ProfileSetupCubit({
    required GetOnboardingGoals getOnboardingGoals,
    required GetBattleGroups getBattleGroups,
    required DoSetupProfile doSetupProfile,
    required CheckPhoneUnique checkPhoneUnique,
  })  : _getOnboardingGoals = getOnboardingGoals,
        _getBattleGroups = getBattleGroups,
        _doSetupProfile = doSetupProfile,
        _checkPhoneUnique = checkPhoneUnique,
        super(const ProfileSetupInitial());

  Future<void> fetchGoals() async {
    emit(const ProfileSetupLoading());
    final res = await _getOnboardingGoals(const NoParams());

    res.fold(
      (failure) => emit(ProfileSetupFailure(failure.message, failure.type)),
      (goals) => emit(ProfileSetupGoalsLoaded(goals)),
    );
  }

  Future<void> fetchGroups(String goalId) async {
    emit(const ProfileSetupLoading());
    final res = await _getBattleGroups(goalId);

    res.fold(
      (failure) => emit(ProfileSetupFailure(failure.message, failure.type)),
      (groups) => emit(ProfileSetupGroupsLoaded(groups)),
    );
  }

  Future<void> setupProfile({
    required String userId,
    required String goalId,
    required String groupId,
    required String institution,
    required String district,
    required String phone,
    required String gender,
    required String dob,
    String howDidYouHear = '',
    String dailyGoal = '',
    List<String> learningModes = const [],
  }) async {
    emit(const ProfileSetupLoading());
    final res = await _doSetupProfile(
      SetupProfileParams(
        userId: userId,
        goalId: goalId,
        groupId: groupId,
        institution: institution,
        district: district,
        phone: phone,
        gender: gender,
        dob: dob,
        howDidYouHear: howDidYouHear,
        dailyGoal: dailyGoal,
        learningModes: learningModes,
      ),
    );

    res.fold(
      (failure) => emit(ProfileSetupFailure(failure.message, failure.type)),
      (lockedUntil) => emit(ProfileSetupSuccess(lockedUntil)),
    );
  }

  Future<bool> checkPhoneUnique(String phone) async {
    final res = await _checkPhoneUnique(phone);
    
    return res.fold(
      (failure) {
        emit(ProfileSetupFailure(failure.message, failure.type));
        return false;
      },
      (isUnique) {
        return isUnique;
      },
    );
  }
}