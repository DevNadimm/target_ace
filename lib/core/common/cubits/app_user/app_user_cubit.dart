import 'package:target_ace/core/common/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

/// Global cubit that holds the current authenticated user state.
///
/// This is a **core-level** cubit â€” not tied to any specific feature.
/// The AuthBloc (in the auth feature) calls `updateUser()` after
/// successful login/signup, and the whole app reacts via BlocSelector.
///
/// Usage in AuthBloc:
/// ```dart
/// void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
///   _appUserCubit.updateUser(user);
///   emit(AuthSuccess(user));
/// }
/// ```
///
/// Usage in UI (root navigation):
/// ```dart
/// BlocSelector<AppUserCubit, AppUserState, bool>(
///   selector: (state) => state is AppUserLoggedIn,
///   builder: (context, isLoggedIn) {
///     return isLoggedIn ? HomePage() : LoginPage();
///   },
/// )
/// ```
class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserInitial());
    } else {
      emit(AppUserLoggedIn(user));
    }
  }

  /// Convenience getter for the current user (null if not logged in).
  User? get currentUser {
    final s = state;
    if (s is AppUserLoggedIn) return s.user;
    return null;
  }

  /// Check if user is currently logged in.
  bool get isLoggedIn => state is AppUserLoggedIn;

  /// Logout â€” resets state to initial.
  void logout() => emit(AppUserInitial());
}