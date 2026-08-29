import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:target_ace/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:target_ace/core/usecase/usecase.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/auth/domain/entities/auth_result.dart';
import 'package:target_ace/features/auth/domain/usecases/do_google_sign_in.dart';
import 'package:target_ace/features/auth/domain/usecases/do_logout.dart';
import 'package:target_ace/features/auth/domain/usecases/do_local_logout.dart';
import 'package:target_ace/features/auth/domain/usecases/do_delete_account.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DoGoogleSignIn _doGoogleSignIn;
  final DoLogout _doLogout;
  final DoLocalLogout _doLocalLogout;
  final DoDeleteAccount _doDeleteAccount;
  final AppUserCubit _appUserCubit;
  final supabase.SupabaseClient _supabaseClient;
  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  AuthBloc({
    required DoGoogleSignIn doGoogleSignIn,
    required DoLogout doLogout,
    required DoLocalLogout doLocalLogout,
    required DoDeleteAccount doDeleteAccount,
    required AppUserCubit appUserCubit,
    required supabase.SupabaseClient supabaseClient,
  })  : _doGoogleSignIn = doGoogleSignIn,
        _doLogout = doLogout,
        _doLocalLogout = doLocalLogout,
        _doDeleteAccount = doDeleteAccount,
        _appUserCubit = appUserCubit,
        _supabaseClient = supabaseClient,
        super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<LogoutRequested>(_onLogout);
    on<DeleteAccountRequested>(_onDeleteAccount);
    on<AuthSignedOut>(_onAuthSignedOut);

    _authStateSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) {
      if (data.event == supabase.AuthChangeEvent.signedOut) {
        add(AuthSignedOut());
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
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
    if (state is LogoutSuccess || state is AccountDeletedSuccess) return;
    
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

  Future<void> _onDeleteAccount(DeleteAccountRequested event, Emitter<AuthState> emit) async {
    if (state is LogoutSuccess || state is AccountDeletedSuccess) return;
    emit(AuthLoading());

    final res = await _doDeleteAccount(const NoParams());

    res.fold(
      (failure) => emit(AuthFailure(ErrorType.server, failure.message)),
      (_) {
        // Clear global user state in cubit
        _appUserCubit.logout();
        emit(AccountDeletedSuccess());
      },
    );
  }

  Future<void> _onAuthSignedOut(AuthSignedOut event, Emitter<AuthState> emit) async {
    if (state is LogoutSuccess || state is AccountDeletedSuccess) return;

    final res = await _doLocalLogout(const NoParams());
    
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