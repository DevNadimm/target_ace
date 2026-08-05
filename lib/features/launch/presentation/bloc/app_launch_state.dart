part of 'app_launch_bloc.dart';

/// Sealed state hierarchy for the app launch state machine.
///
/// Each state maps to exactly one screen. The coordinator emits
/// exactly one terminal state per launch cycle.
sealed class AppLaunchState {
  const AppLaunchState();
}

/// Initial state â€” splash screen with logo + loader.
final class AppLaunchInitializing extends AppLaunchState {
  const AppLaunchInitializing();
}

/// Show the onboarding carousel (first-time install).
final class AppLaunchShowOnboarding extends AppLaunchState {
  const AppLaunchShowOnboarding();
}

/// Show the login page (no active session).
final class AppLaunchShowLogin extends AppLaunchState {
  const AppLaunchShowLogin();
}

/// Show the profile setup wizard (profile incomplete).
final class AppLaunchShowProfileSetup extends AppLaunchState {
  const AppLaunchShowProfileSetup();
}

/// Show the notification permission prompt.
final class AppLaunchShowNotificationPermission extends AppLaunchState {
  const AppLaunchShowNotificationPermission();
}

/// Show the free trial offer page.
final class AppLaunchShowFreeTrial extends AppLaunchState {
  const AppLaunchShowFreeTrial();
}

/// Terminal state â€” navigate to home/home.
final class AppLaunchNavigateHome extends AppLaunchState {
  const AppLaunchNavigateHome();
}

/// Error state â€” unrecoverable launch failure.
final class AppLaunchError extends AppLaunchState {
  final String message;
  const AppLaunchError(this.message);
}