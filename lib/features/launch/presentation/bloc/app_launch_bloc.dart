import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/services/user_local_datasource.dart';
import 'package:target_ace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:target_ace/features/auth/domain/repository/auth_repository.dart';
import 'package:target_ace/features/subscription/domain/usecases/check_trial_eligibility.dart';

part 'app_launch_event.dart';
part 'app_launch_state.dart';

/// Central coordinator BLoC for the entire app launch flow.
///
/// Implements a deterministic state machine:
/// ```
/// Initializing â†’ CheckOnboarding â†’ CheckAuth â†’ SyncProfile
///   â†’ CheckProfile â†’ CheckNotification â†’ CheckTrial â†’ Home
/// ```
///
/// **Key invariants**:
/// - Exactly one navigation decision per app launch.
/// - No navigation logic lives in individual pages.
/// - All user-specific flags are scoped by userId.
/// - OS-level notification permission is checked before showing the prompt.
/// - Network failures fall back to cached data for authenticated users.
class AppLaunchBloc extends Bloc<AppLaunchEvent, AppLaunchState> {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthRepository _authRepository;
  final ConnectionChecker _connectionChecker;
  final CheckTrialEligibility _checkTrialEligibility;

  AppLaunchBloc({
    required AuthRemoteDataSource authRemoteDataSource,
    required AuthRepository authRepository,
    required ConnectionChecker connectionChecker,
    required CheckTrialEligibility checkTrialEligibility,
  })  : _authRemoteDataSource = authRemoteDataSource,
        _authRepository = authRepository,
        _connectionChecker = connectionChecker,
        _checkTrialEligibility = checkTrialEligibility,
        super(const AppLaunchInitializing()) {
    on<AppLaunchStarted>(_onAppLaunchStarted);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<LoginCompleted>(_onLoginCompleted);
    on<ProfileSetupCompleted>(_onProfileSetupCompleted);
    on<NotificationPermissionHandled>(_onNotificationPermissionHandled);
    on<FreeTrialHandled>(_onFreeTrialHandled);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Event Handlers
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Entry point: runs the full state machine from the top.
  Future<void> _onAppLaunchStarted(
    AppLaunchStarted event,
    Emitter<AppLaunchState> emit,
  ) async {
    try {
      // Brief splash delay for brand impression
      if (!event.skipDelay) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // â”€â”€ Step 1: Check Onboarding â”€â”€
      final isFirstTime = await AppPreferences.isFirstTime();
      if (isFirstTime) {
        emit(const AppLaunchShowOnboarding());
        return;
      }

      // â”€â”€ Step 2: Check Auth Session â”€â”€
      final session = _authRemoteDataSource.currentSession;
      if (session == null) {
        emit(const AppLaunchShowLogin());
        return;
      }

      // â”€â”€ Step 3: Sync Profile (with offline resilience) â”€â”€
      await _syncProfileWithFallback(emit);

      // â”€â”€ Step 4â€“6: Run remaining checks â”€â”€
      await _runPostAuthChecks(emit);
    } catch (e) {
      debugPrint('AppLaunchBloc._onAppLaunchStarted error: $e');
      emit(AppLaunchError(e.toString()));
    }
  }

  /// Onboarding done â†’ show login.
  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AppLaunchState> emit,
  ) async {
    emit(const AppLaunchShowLogin());
  }

  /// Login succeeded â†’ sync profile â†’ run post-auth checks.
  Future<void> _onLoginCompleted(
    LoginCompleted event,
    Emitter<AppLaunchState> emit,
  ) async {
    try {
      // Profile was already synced during login (AuthRepositoryImpl.googleSignIn
      // calls fetchProfile and saves to UserLocalDataSource). No need to sync again.
      await _runPostAuthChecks(emit);
    } catch (e) {
      debugPrint('AppLaunchBloc._onLoginCompleted error: $e');
      emit(AppLaunchError(e.toString()));
    }
  }

  /// Profile setup saved â†’ check notification â†’ check trial â†’ home.
  Future<void> _onProfileSetupCompleted(
    ProfileSetupCompleted event,
    Emitter<AppLaunchState> emit,
  ) async {
    try {
      await _checkNotificationStep(emit);
    } catch (e) {
      debugPrint('AppLaunchBloc._onProfileSetupCompleted error: $e');
      emit(AppLaunchError(e.toString()));
    }
  }

  /// Notification permission handled â†’ check trial â†’ home.
  Future<void> _onNotificationPermissionHandled(
    NotificationPermissionHandled event,
    Emitter<AppLaunchState> emit,
  ) async {
    try {
      await _checkTrialStep(emit);
    } catch (e) {
      debugPrint('AppLaunchBloc._onNotificationPermissionHandled error: $e');
      emit(AppLaunchError(e.toString()));
    }
  }

  /// Free trial handled â†’ navigate home.
  Future<void> _onFreeTrialHandled(
    FreeTrialHandled event,
    Emitter<AppLaunchState> emit,
  ) async {
    emit(const AppLaunchNavigateHome());
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Internal State Machine Steps
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Syncs profile from Supabase DB. Falls back to cached data if offline.
  Future<void> _syncProfileWithFallback(Emitter<AppLaunchState> emit) async {
    final isProfileLocallyCached = await UserLocalDataSource.isProfileComplete();

    if (isProfileLocallyCached) {
      // Profile exists locally â€” sync in background, don't block the user.
      _authRepository.syncProfile().then((either) {
        either.fold(
          (failure) => debugPrint(
              'AppLaunchBloc: Background sync failed: ${failure.message}'),
          (_) => debugPrint(
              'AppLaunchBloc: Background sync completed successfully.'),
        );
      }).catchError((error) {
        debugPrint('AppLaunchBloc: Background sync unhandled error: $error');
      });
    } else {
      // No local data â€” must sync now.
      final isOnline = await _connectionChecker.isConnected;
      if (isOnline) {
        await _authRepository.syncProfile();
      }
      // If offline with no cached data, profile check will catch it below.
    }
  }

  /// Runs the post-authentication check sequence:
  /// CheckProfile â†’ CheckNotification â†’ CheckTrial â†’ Home
  Future<void> _runPostAuthChecks(Emitter<AppLaunchState> emit) async {
    // â”€â”€ Step 4: Check Profile Completion â”€â”€
    final isProfileComplete = await UserLocalDataSource.isProfileComplete();
    if (!isProfileComplete) {
      emit(const AppLaunchShowProfileSetup());
      return;
    }

    // â”€â”€ Step 5: Check Notification Permission â”€â”€
    await _checkNotificationStep(emit);
  }

  /// Checks if notification permission prompt is needed.
  ///
  /// Criteria for showing the permission page:
  /// 1. User has NOT been prompted before (user-scoped flag).
  /// 2. OS-level permission is NOT already granted.
  Future<void> _checkNotificationStep(Emitter<AppLaunchState> emit) async {
    final hasPrompted =
        await UserLocalDataSource.getHasPromptedNotification();

    if (!hasPrompted) {
      // Also check OS-level permission â€” skip the prompt if already granted.
      bool isAlreadyGranted = false;
      try {
        final settings =
            await FirebaseMessaging.instance.getNotificationSettings();
        isAlreadyGranted =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (e) {
        debugPrint('AppLaunchBloc: Failed to get notification settings: $e');
        // Fail open â€” assume not granted and show the prompt
      }

      if (isAlreadyGranted) {
        // OS permission already granted â€” mark as prompted and move on.
        await UserLocalDataSource.setHasPromptedNotification(true);
      } else {
        emit(const AppLaunchShowNotificationPermission());
        return;
      }
    }

    // Notification handled â€” proceed to trial check.
    await _checkTrialStep(emit);
  }

  /// Checks if the user is eligible for a free trial.
  ///
  /// Logic: DB-first â€” if the database says the user already has/had a trial,
  /// skip. Only falls back to error-safe "not eligible" on failure.
  Future<void> _checkTrialStep(Emitter<AppLaunchState> emit) async {
    final userId = await UserLocalDataSource.getUserId();

    if (userId.isNotEmpty) {
      final hasSkipped = await UserLocalDataSource.getHasSkippedFreeTrial();
      if (hasSkipped) {
        emit(const AppLaunchNavigateHome());
        return;
      }

      try {
        final res = await _checkTrialEligibility(userId);
        final isEligible = res.fold((_) => false, (eligible) => eligible);

        if (isEligible) {
          emit(const AppLaunchShowFreeTrial());
          return;
        }
      } catch (e) {
        // On error, fail open â€” skip the trial page, go to home.
        debugPrint('AppLaunchBloc: Trial eligibility check failed: $e');
      }
    }

    emit(const AppLaunchNavigateHome());
  }
}