import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/auth/data/models/auth_model.dart';
import 'package:target_ace/features/auth/data/repos/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onGoogleSignIn(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final authModel = await AuthRepo.googleSignIn();
      emit(AuthSuccess(authModel));
    } on AuthException catch (e) {
      emit(AuthFailure(ErrorType.unknown, e.message));
    } catch (e) {
      emit(AuthFailure(ErrorType.server, _mapError(e)));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await AuthRepo.logout();
    emit(LogoutSuccess());
  }

  String _mapError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('provider_disabled') || s.contains('not enabled') || s.contains('accounts.google.com')) {
      return 'Google Sign-In is temporarily unavailable. Please contact support.';
    }
    if (s.contains('socketexception') || s.contains('network') || s.contains('clientexception')) {
      return 'No internet connection. Please try again.';
    }
    if (s.contains('canceled') || s.contains('12501') || s.contains('sign_in_failed')) {
      return 'Sign-in was cancelled.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
