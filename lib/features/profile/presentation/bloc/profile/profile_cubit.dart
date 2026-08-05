import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/features/profile/domain/entities/profile_entity.dart';
import 'package:target_ace/features/profile/domain/usecases/get_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfile _getProfile;
  StreamSubscription<dynamic>? _profileSubscription;

  ProfileCubit({
    required GetProfile getProfile,
  })  : _getProfile = getProfile,
        super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    await _profileSubscription?.cancel();
    
    _profileSubscription = _getProfile(const NoParams()).listen(
      (res) {
        res.fold(
          (failure) => emit(ProfileFailure(failure.message)),
          (profileData) {
            if (state is ProfileLoaded) {
              final current = (state as ProfileLoaded).profileData;
              if (current != profileData) {
                emit(ProfileLoaded(profileData));
              }
            } else {
              emit(ProfileLoaded(profileData));
            }
          },
        );
      },
      onError: (e) {
        emit(ProfileFailure(e.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    return super.close();
  }
}