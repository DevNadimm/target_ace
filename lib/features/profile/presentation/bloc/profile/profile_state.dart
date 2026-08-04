part of 'profile_cubit.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profileData;
  const ProfileLoaded(this.profileData);
}

class ProfileFailure extends ProfileState {
  final String error;
  const ProfileFailure(this.error);
}
