part of 'app_launch_bloc.dart';

/// Events that drive the app launch state machine.
///
/// [AppLaunchStarted] is the only internal event. All others are
/// completion signals emitted by pages back to the coordinator.
sealed class AppLaunchEvent {
  const AppLaunchEvent();
}

/// Triggered once on app start to begin the launch flow.
final class AppLaunchStarted extends AppLaunchEvent {
  final bool skipDelay;
  const AppLaunchStarted({this.skipDelay = false});
}

/// Emitted by [OnboardingPage] when the user finishes onboarding.
final class OnboardingCompleted extends AppLaunchEvent {
  const OnboardingCompleted();
}

/// Emitted when the user logs out or deletes their account to reset coordinator to login screen.
final class AppLaunchLoggedOut extends AppLaunchEvent {
  const AppLaunchLoggedOut();
}

/// Emitted by [LoginPage] when authentication succeeds.
final class LoginCompleted extends AppLaunchEvent {
  const LoginCompleted();
}

/// Emitted by [ProfileSetupPage] when profile setup is saved.
final class ProfileSetupCompleted extends AppLaunchEvent {
  const ProfileSetupCompleted();
}

/// Emitted by [NotificationPermissionPage] on accept or skip.
final class NotificationPermissionHandled extends AppLaunchEvent {
  const NotificationPermissionHandled();
}

/// Emitted by [FreeTrialOfferPage] on claim or dismiss.
final class FreeTrialHandled extends AppLaunchEvent {
  const FreeTrialHandled();
}