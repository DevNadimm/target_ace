import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:target_ace/core/error/failure.dart';
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
/// Initializing -> CheckOnboarding -> CheckAuth -> SyncProfile
///   -> CheckProfile -> CheckNotification -> CheckTrial -> Home
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
    on<AppLaunchLoggedOut>(_onAppLaunchLoggedOut);
    on<LoginCompleted>(_onLoginCompleted);
    on<ProfileSetupCompleted>(_onProfileSetupCompleted);
    on<NotificationPermissionHandled>(_onNotificationPermissionHandled);
    on<FreeTrialHandled>(_onFreeTrialHandled);
  }

  // --------------------------------------------------
  // Event Handlers
  // --------------------------------------------------

  /// Entry point: runs the full state machine from the top.
  Future<void> _onAppLaunchStarted(
    AppLaunchStarted event,
    Emitter<AppLaunchState> emit,
  ) async {
    emit(const AppLaunchInitializing());
    try {
      // Brief splash delay for brand impression
      if (!event.skipDelay) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // -- Step 1: Check Onboarding --
      final isFirstTime = await AppPreferences.isFirstTime();
      if (isFirstTime) {
        emit(const AppLaunchShowOnboarding());
        return;
      }

      // -- Step 2: Check Auth Session --
      final session = _authRemoteDataSource.currentSession;
      if (session == null) {
        emit(const AppLaunchShowLogin());
        return;
      }

      // -- Step 3: Sync Profile (with offline resilience) --
      await _syncProfileWithFallback(emit);

      // If sync emitted an error (e.g. offline + no cache), stop here.
      if (state is AppLaunchError) return;

      // -- Step 4-6: Run remaining checks --
      await _runPostAuthChecks(emit);
    } catch (e) {
      debugPrint('AppLaunchBloc._onAppLaunchStarted error: $e');
      emit(AppLaunchError(e.toString()));
    }
  }

  /// Onboarding done -> show login.
  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AppLaunchState> emit,
  ) async {
    emit(const AppLaunchShowLogin());
  }

  /// User logged out or deleted account -> reset state directly to login.
  Future<void> _onAppLaunchLoggedOut(
    AppLaunchLoggedOut event,
    Emitter<AppLaunchState> emit,
  ) async {
    emit(const AppLaunchShowLogin());
  }

  /// Login succeeded -> sync profile -> run post-auth checks.
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

  /// Profile setup saved -> check notification -> check trial -> home.
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

  /// Notification permission handled -> check trial -> home.
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

  /// Free trial handled -> navigate home.
  Future<void> _onFreeTrialHandled(
    FreeTrialHandled event,
    Emitter<AppLaunchState> emit,
  ) async {
    emit(const AppLaunchNavigateHome());
  }

  // --------------------------------------------------
  // Internal State Machine Steps
  // --------------------------------------------------

  /// Syncs profile from Supabase DB. Falls back to cached data if offline.
  ///
  /// For cached users: awaits sync with a 4-second timeout so navigation
  /// decisions always use the freshest available data.
  /// For uncached users: must sync or fail with an error state.
  Future<void> _syncProfileWithFallback(Emitter<AppLaunchState> emit) async {
    final isProfileLocallyCached = await UserLocalDataSource.isProfileComplete();

    if (isProfileLocallyCached) {
      // Profile exists locally -- sync with timeout so we don't block forever,
      // but still get fresh data before making navigation decisions.
      try {
        await _authRepository.syncProfile().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint('AppLaunchBloc: Profile sync timed out, using cached data.');
            return left(Failure(message: 'Sync timeout'));
          },
        );
      } catch (e) {
        debugPrint('AppLaunchBloc: Profile sync failed, using cached data: $e');
      }
    } else {
      // No local data -- must sync now.
      final isOnline = await _connectionChecker.isConnected;
      if (isOnline) {
        await _authRepository.syncProfile();
      }
    }

    // Safety check: if after sync attempt there's still no cached user,
    // we cannot proceed (offline + no cache). Show error instead of
    // falling through to a broken Profile Setup screen.
    final hasUser = await UserLocalDataSource.readUser();
    if (hasUser == null) {
      emit(const AppLaunchError(
        'Unable to load your profile. Please check your internet connection and restart the app.',
      ));
      return;
    }
  }

  /// Runs the post-authentication check sequence:
  /// CheckProfile -> CheckNotification -> CheckTrial -> Home
  Future<void> _runPostAuthChecks(Emitter<AppLaunchState> emit) async {
    if (_authRemoteDataSource.currentSession == null) return;

    // -- Step 4: Check Profile Completion --
    final isProfileComplete = await UserLocalDataSource.isProfileComplete();
    
    if (_authRemoteDataSource.currentSession == null) return;
    if (!isProfileComplete) {
      emit(const AppLaunchShowProfileSetup());
      return;
    }

    // -- Step 5: Check Notification Permission --
    await _checkNotificationStep(emit);
  }

  /// Checks if notification permission prompt is needed.
  Future<void> _checkNotificationStep(Emitter<AppLaunchState> emit) async {
    if (_authRemoteDataSource.currentSession == null) return;

    final hasPrompted =
        await UserLocalDataSource.getHasPromptedNotification();

    if (!hasPrompted) {
      // Also check OS-level permission -- skip the prompt if already granted.
      bool isAlreadyGranted = false;
      try {
        final settings =
            await FirebaseMessaging.instance.getNotificationSettings();
        isAlreadyGranted =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus == AuthorizationStatus.provisional;
      } catch (e) {
        debugPrint('AppLaunchBloc: Failed to get notification settings: $e');
      }

      if (isAlreadyGranted) {
        await UserLocalDataSource.setHasPromptedNotification(true);
      } else {
        emit(const AppLaunchShowNotificationPermission());
        return;
      }
    }

    if (_authRemoteDataSource.currentSession == null) return;
    // Notification handled -- proceed to trial check.
    await _checkTrialStep(emit);
  }

  /// Checks if the user is eligible for a free trial.
  Future<void> _checkTrialStep(Emitter<AppLaunchState> emit) async {
    if (_authRemoteDataSource.currentSession == null) return;

    final userId = await UserLocalDataSource.getUserId();

    if (userId.isNotEmpty) {
      final hasSkipped = await UserLocalDataSource.getHasSkippedFreeTrial();
      
      if (_authRemoteDataSource.currentSession == null) return;
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
        // On error, fail open -- skip the trial page, go to home.
        debugPrint('AppLaunchBloc: Trial eligibility check failed: $e');
      }
    }

    emit(const AppLaunchNavigateHome());
  }
}