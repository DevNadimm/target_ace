import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/auth/domain/entities/auth_result.dart';
import 'package:target_ace/features/auth/domain/usecases/do_google_sign_in.dart';
import 'package:target_ace/features/auth/domain/usecases/do_logout.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DoGoogleSignIn _doGoogleSignIn;
  final DoLogout _doLogout;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required DoGoogleSignIn doGoogleSignIn,
    required DoLogout doLogout,
    required AppUserCubit appUserCubit,
  })  : _doGoogleSignIn = doGoogleSignIn,
        _doLogout = doLogout,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onGoogleSignIn(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _doGoogleSignIn(const NoParams());

    res.fold(
      (failure) {
        if (failure.message == 'CANCELED_BY_USER') {
          emit(AuthInitial());
        } else {
          emit(AuthFailure(ErrorType.server, failure.message));
        }
      },
      (authResult) {
        // Update the global AppUserCubit auth state
        _appUserCubit.updateUser(authResult.user);
        emit(AuthSuccess(authResult));
      },
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    final res = await _doLogout(const NoParams());
    
    res.fold(
      (failure) => emit(AuthFailure(ErrorType.server, failure.message)),
      (_) {
        // Clear global user state in cubit
        _appUserCubit.logout();
        emit(LogoutSuccess());
      },
    );
  }
}