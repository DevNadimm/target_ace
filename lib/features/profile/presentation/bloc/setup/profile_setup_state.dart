part of 'profile_setup_cubit.dart';

sealed class ProfileSetupState {
  const ProfileSetupState();
}

class ProfileSetupInitial extends ProfileSetupState {
  const ProfileSetupInitial();
}

class ProfileSetupLoading extends ProfileSetupState {
  const ProfileSetupLoading();
}

class ProfileSetupGoalsLoaded extends ProfileSetupState {
  final List<OnboardingGoalEntity> goals;
  const ProfileSetupGoalsLoaded(this.goals);
}

class ProfileSetupGroupsLoaded extends ProfileSetupState {
  final List<BattleGroupEntity> groups;
  const ProfileSetupGroupsLoaded(this.groups);
}

class ProfileSetupSuccess extends ProfileSetupState {
  final String lockedUntil;
  const ProfileSetupSuccess(this.lockedUntil);
}

class ProfileSetupFailure extends ProfileSetupState {
  final String error;
  const ProfileSetupFailure(this.error);
}
