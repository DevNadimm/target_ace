part of 'app_user_cubit.dart';

/// States for [AppUserCubit].
///
/// Sealed class ensures exhaustive pattern matching in switch/if.
sealed class AppUserState {
  const AppUserState();
}

/// Initial state â€” no user is logged in.
final class AppUserInitial extends AppUserState {
  const AppUserInitial();
}

/// User is authenticated and available.
final class AppUserLoggedIn extends AppUserState {
  final User user;
  const AppUserLoggedIn(this.user);
}