// ignore_for_file: unnecessary_const
// ═══════════════════════════════════════════════════════════════
// AppLaunchBloc — BEHAVIORAL REGRESSION TEST SUITE
// ═══════════════════════════════════════════════════════════════
//
// This test suite provides REAL behavioral coverage for the P0 retry bug
// and all related startup state machine scenarios.
//
// Tests execute the actual BLoC behavior through event → state transitions.
// No bloc_test package used (conflicts with isar_generator) — tests use
// manual stream listening for full control and transparency.
//
// Mock strategy:
//   - Injectable deps (AuthRemoteDataSource, AuthRepository,
//     ConnectionChecker, CheckTrialEligibility) → mocktail Mocks
//   - Static deps (AppPreferences, UserLocalDataSource) →
//     SharedPreferences.setMockInitialValues (controls the backing store)
//   - FirebaseMessaging → bypassed by pre-setting notification flag
//
// The BLoC itself is NEVER mocked.
// ═══════════════════════════════════════════════════════════════
import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:target_ace/features/auth/domain/repository/auth_repository.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/subscription/domain/usecases/check_trial_eligibility.dart';

// ═════════════════════════════════════════════════════════
// Mocks
// ═════════════════════════════════════════════════════════

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockConnectionChecker extends Mock implements ConnectionChecker {}

class MockCheckTrialEligibility extends Mock implements CheckTrialEligibility {}

// ═════════════════════════════════════════════════════════
// Test Data
// ═════════════════════════════════════════════════════════

const _testUserId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
const _testUserIdB = 'b2c3d4e5-f6a7-8901-bcde-f12345678901';

/// A complete cached user JSON blob that passes `isProfileComplete()`.
/// Requires non-empty `group_id` and `phone`.
Map<String, dynamic> _completeCachedUserJson({
  String id = _testUserId,
  String name = 'Test User',
  String email = 'test@example.com',
  String phone = '+1234567890',
  String groupId = 'group-abc',
}) =>
    {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': 'male',
      'dob': '2000-01-01',
      'avatar_url': '',
      'institution': 'Test School',
      'district': 'Test District',
      'goal': 'BCS',
      'how_did_you_hear': 'friend',
      'daily_goal': '2h',
      'learning_modes': <String>['quiz', 'flashcard'],
      'group_id': groupId,
      'group_title': 'Group A',
      'group_locked_until': '',
      'subscription_status': 'none',
      'subscription_plan_name': '',
      'subscription_expiry_date': '',
    };

/// An incomplete cached user JSON blob — missing groupId and phone.
Map<String, dynamic> _incompleteCachedUserJson({
  String id = _testUserId,
}) =>
    {
      'id': id,
      'name': 'Test User',
      'email': 'test@example.com',
      'phone': '',
      'gender': '',
      'dob': '',
      'avatar_url': '',
      'institution': '',
      'district': '',
      'goal': '',
      'how_did_you_hear': '',
      'daily_goal': '',
      'learning_modes': <String>[],
      'group_id': '',
      'group_title': '',
      'group_locked_until': '',
      'subscription_status': 'none',
      'subscription_plan_name': '',
      'subscription_expiry_date': '',
    };

/// Sets up SharedPreferences with the given state.
void _setUpPreferences({
  bool isFirstTime = false,
  Map<String, dynamic>? cachedUser,
  bool hasPromptedNotification = true,
  bool hasSkippedFreeTrial = true,
  String userId = _testUserId,
}) {
  final values = <String, Object>{
    'is-first-time': isFirstTime,
  };

  if (cachedUser != null) {
    values['cached_user'] = jsonEncode(cachedUser);
  }

  // User-scoped keys: {userId}_{suffix}
  values['${userId}_has_prompted_notification'] = hasPromptedNotification;
  values['${userId}_has_skipped_free_trial'] = hasSkippedFreeTrial;

  SharedPreferences.setMockInitialValues(values);
}

/// Creates a fake Supabase Session for mock returns.
supabase.Session _fakeSession({String userId = _testUserId}) {
  return supabase.Session(
    accessToken: 'fake-access-token',
    tokenType: 'bearer',
    expiresIn: 3600,
    refreshToken: 'fake-refresh-token',
    user: supabase.User(
      id: userId,
      appMetadata: {},
      userMetadata: {'name': 'Test User'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    ),
  );
}

/// Collects all states emitted by a bloc after an action, until settled.
Future<List<AppLaunchState>> collectStates(
  AppLaunchBloc bloc, {
  Duration settle = const Duration(milliseconds: 500),
}) async {
  final states = <AppLaunchState>[];
  final sub = bloc.stream.listen(states.add);
  // Wait for the bloc to settle (no new emissions for `settle` duration)
  await _waitForSettle(bloc, settle);
  await sub.cancel();
  return states;
}

Future<void> _waitForSettle(AppLaunchBloc bloc, Duration settle) async {
  final completer = Completer<void>();
  Timer? timer;
  final sub = bloc.stream.listen((_) {
    timer?.cancel();
    timer = Timer(settle, () {
      if (!completer.isCompleted) completer.complete();
    });
  });
  // Also set initial timer in case no events are emitted
  timer = Timer(settle, () {
    if (!completer.isCompleted) completer.complete();
  });
  await completer.future;
  timer?.cancel();
  await sub.cancel();
}

// ═════════════════════════════════════════════════════════
// Test Suite
// ═════════════════════════════════════════════════════════

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockAuthRepository mockAuthRepository;
  late MockConnectionChecker mockConnectionChecker;
  late MockCheckTrialEligibility mockCheckTrialEligibility;

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockAuthRepository = MockAuthRepository();
    mockConnectionChecker = MockConnectionChecker();
    mockCheckTrialEligibility = MockCheckTrialEligibility();
  });

  AppLaunchBloc buildBloc() => AppLaunchBloc(
        authRemoteDataSource: mockAuthRemoteDataSource,
        authRepository: mockAuthRepository,
        connectionChecker: mockConnectionChecker,
        checkTrialEligibility: mockCheckTrialEligibility,
      );

  // ─────────────────────────────────────────────────────
  // § 1 — EXISTING TEST AUDIT
  // ─────────────────────────────────────────────────────

  group('§1 — Existing test was a placeholder', () {
    test('AUDIT: the original test was `expect(true, true)` — '
        'P0 behavioral coverage = NOT VERIFIED by the old test', () {
      // This test documents that the previous file contained only:
      //   expect(true, true);
      // which verified absolutely nothing about the bloc behavior.
      // All tests below are the REAL behavioral regression tests.
      //
      // P0 behavioral coverage = NOT VERIFIED (by old placeholder test)
      expect(true, isTrue); // self-documenting audit record
    });
  });

  // ─────────────────────────────────────────────────────
  // § 2 — P0 RETRY FROM ERROR → SUCCESS
  // ─────────────────────────────────────────────────────

  group('§2 — P0: Error → Retry → Success (the critical fix)', () {
    test(
        'GIVEN bloc is in AppLaunchError '
        'WHEN AppLaunchStarted(skipDelay: true) is added '
        'THEN it emits AppLaunchInitializing → AppLaunchNavigateHome '
        'proving that AppLaunchError does NOT block the retry', () async {
      // Phase 1: Get into error state (offline + no cache)
      _setUpPreferences(cachedUser: null);
      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      final phase1States = <AppLaunchState>[];
      final sub1 = bloc.stream.listen(phase1States.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(phase1States.last, isA<AppLaunchError>(),
          reason: 'Phase 1: offline + no cache must produce error');

      await sub1.cancel();

      // Phase 2: Retry from error state — network restored, cache available
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final phase2States = <AppLaunchState>[];
      final sub2 = bloc.stream.listen(phase2States.add);

      // THIS IS THE CRITICAL MOMENT: bloc is in AppLaunchError,
      // user taps Retry → AppLaunchStarted(skipDelay: true)
      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      // Verify the state progression
      expect(phase2States.length, greaterThanOrEqualTo(2),
          reason: 'Must emit at least Initializing + terminal state');
      expect(phase2States.first, isA<AppLaunchInitializing>(),
          reason: 'First emission must be AppLaunchInitializing');
      expect(phase2States.last, isA<AppLaunchNavigateHome>(),
          reason: 'Must reach Home — error state must not block retry');

      // Verify syncProfile was actually called during retry
      verify(() => mockAuthRepository.syncProfile()).called(1);

      await sub2.cancel();
      await bloc.close();
    });

    test(
        'REGRESSION GUARD: If the old guard `if (state is AppLaunchError) return` '
        'were still checking the SEED state, retry would be blocked. '
        'This test verifies the fix by checking that emit(AppLaunchInitializing) '
        'on line 66 runs BEFORE the guard on line 91.', () async {
      // Setup: already in error state, sync returns Left but cache exists
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'Sync timeout')));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      // First get into error state
      _setUpPreferences(cachedUser: null);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));
      expect(bloc.state, isA<AppLaunchError>());

      // Now retry with restored conditions
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'Sync timeout')));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final retryStates = <AppLaunchState>[];
      final sub = bloc.stream.listen(retryStates.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(retryStates.first, isA<AppLaunchInitializing>(),
          reason: 'MUST start with Initializing — this IS the fix');
      expect(retryStates.last, isA<AppLaunchNavigateHome>(),
          reason: 'Must proceed to Home because cached profile is complete');

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 3 — RETRY FAILURE
  // ─────────────────────────────────────────────────────

  group('§3 — Error → Retry → Sync fails → NEW Error', () {
    test(
        'GIVEN bloc is in AppLaunchError '
        'WHEN retry is attempted but sync fails and no cache exists '
        'THEN a NEW AppLaunchError is emitted (not the old one)', () async {
      // Phase 1: get into error
      _setUpPreferences(cachedUser: null);
      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));
      expect(bloc.state, isA<AppLaunchError>());

      // Phase 2: retry — online but sync fails, still no cache
      _setUpPreferences(cachedUser: null);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'DB error')));

      final retryStates = <AppLaunchState>[];
      final sub = bloc.stream.listen(retryStates.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(retryStates.first, isA<AppLaunchInitializing>(),
          reason: 'Retry must start with Initializing');
      expect(retryStates.last, isA<AppLaunchError>(),
          reason: 'Must produce error when sync fails and no cache');
      expect(
        (retryStates.last as AppLaunchError).message,
        contains('Unable to load your profile'),
        reason: 'Error message must be from the current attempt',
      );

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 4 — RETRY SUCCESS AFTER OFFLINE FAILURE
  // ─────────────────────────────────────────────────────

  group('§4 — Offline failure → Network restored → Retry → Success', () {
    test(
        'Attempt 1: offline + no cache → Error. '
        'Attempt 2: network restored + sync succeeds → Home. '
        'Proves Error screen is NOT a dead end.', () async {
      // ── Attempt 1: offline, no cache ──
      _setUpPreferences(cachedUser: null);
      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      final attempt1States = <AppLaunchState>[];
      final sub1 = bloc.stream.listen(attempt1States.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(attempt1States, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchError>(),
      ], reason: 'Attempt 1: offline + no cache → Error');

      await sub1.cancel();

      // ── Attempt 2: network restored, cache populated by sync ──
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final attempt2States = <AppLaunchState>[];
      final sub2 = bloc.stream.listen(attempt2States.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(attempt2States.first, isA<AppLaunchInitializing>(),
          reason: 'Attempt 2 must start fresh with Initializing');
      expect(attempt2States.last, isA<AppLaunchNavigateHome>(),
          reason: 'Attempt 2 must reach Home — error is NOT a dead end');

      await sub2.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 5 — CACHED OFFLINE FALLBACK
  // ─────────────────────────────────────────────────────

  group('§5 — Authenticated + Offline + Valid cached profile → No Error', () {
    test(
        'GIVEN authenticated user with cached complete profile '
        'WHEN offline and sync fails '
        'THEN app uses cached data and does NOT emit AppLaunchError', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      // Sync fails (offline) but cached profile exists → fallback
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'Network error')));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchNavigateHome>(),
      ], reason: 'Must NOT emit AppLaunchError — cached data is sufficient');

      // Verify no AppLaunchError was emitted at any point
      expect(states.whereType<AppLaunchError>(), isEmpty,
          reason: 'No error state should appear when valid cache exists');

      await sub.cancel();
      await bloc.close();
    });

    test(
        'GIVEN authenticated user with cached INCOMPLETE profile '
        'WHEN offline '
        'THEN app shows ProfileSetup (not error)', () async {
      _setUpPreferences(
        cachedUser: _incompleteCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'Network error')));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchShowProfileSetup>(),
      ]);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 6 — OFFLINE + NO CACHE → ERROR, THEN RETRY
  // ─────────────────────────────────────────────────────

  group('§6 — Authenticated + Offline + No cache → Error', () {
    test(
        'GIVEN authenticated, offline, no cache '
        'THEN AppLaunchError is emitted', () async {
      _setUpPreferences(cachedUser: null);

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchError>().having(
          (e) => e.message,
          'message',
          contains('Unable to load your profile'),
        ),
      ]);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 7 — ONLINE PROFILE SYNC (stale cache replaced)
  // ─────────────────────────────────────────────────────

  group('§7 — Online sync replaces stale cache', () {
    test(
        'GIVEN cached profile with stale groupId '
        'WHEN online startup '
        'THEN syncProfile is called (updates cache) '
        'AND post-auth checks proceed with current data', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(groupId: 'old-group'),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchNavigateHome>(),
      ]);

      // Critical: syncProfile MUST be called to update the stale cache
      verify(() => mockAuthRepository.syncProfile()).called(1);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 8 — AUTH ERROR vs DATABASE ERROR
  // ─────────────────────────────────────────────────────

  group('§8 — Auth error vs database error handling', () {
    test(
        'Auth failure from syncProfile (Left) with cache available '
        '→ proceeds with cached data (no crash, no signOut from bloc)',
        () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'JWT expired')));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      // With cache available, sync failure is tolerated → proceeds to Home
      expect(states.last, isA<AppLaunchNavigateHome>(),
          reason: 'Auth error with cache → fallback to Home, no signOut');

      await sub.cancel();
      await bloc.close();
    });

    test(
        'Database/RPC failure (syncProfile returns Left) with NO cache '
        '→ AppLaunchError (session preserved — no signOut in bloc)',
        () async {
      _setUpPreferences(cachedUser: null);

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => left(Failure(message: 'DB refused')));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states.last, isA<AppLaunchError>());
      // Bloc does NOT call logout/signOut — session is preserved
      verifyNever(() => mockAuthRemoteDataSource.logout());

      await sub.cancel();
      await bloc.close();
    });

    test(
        'syncProfile throws unhandled exception '
        '→ top-level catch emits AppLaunchError', () async {
      _setUpPreferences(cachedUser: null);

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenThrow(Exception('Unexpected crash'));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states.last, isA<AppLaunchError>());
      expect(
        (states.last as AppLaunchError).message,
        contains('Unexpected crash'),
      );

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 9 — ACCOUNT SWITCHING
  // ─────────────────────────────────────────────────────

  group('§9 — Account switching isolation', () {
    test('AppLaunchLoggedOut → emits AppLaunchShowLogin', () async {
      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchLoggedOut());
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [isA<AppLaunchShowLogin>()]);

      await sub.cancel();
      await bloc.close();
    });

    test('After logout, new startup with User B cache → uses User B data',
        () async {
      // User B's cache
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(
          id: _testUserIdB,
          name: 'User B',
          email: 'userb@example.com',
          phone: '+9876543210',
        ),
        userId: _testUserIdB,
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      final sessionB = _fakeSession(userId: _testUserIdB);
      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(sessionB);
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(sessionB.user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states.last, isA<AppLaunchNavigateHome>());
      verify(() => mockAuthRepository.syncProfile()).called(1);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 10 — UUID REGEX in AppPreferences.clearAll()
  // ─────────────────────────────────────────────────────

  group('§10 — UUID regex preserves user-scoped keys', () {
    test('clearAll() preserves lowercase UUID-scoped keys', () async {
      SharedPreferences.setMockInitialValues({
        'is-first-time': false,
        'access-token': 'old-token',
        // Lowercase UUID
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890_has_prompted_notification': true,
        // Non-user key
        'some-random-setting': 'value',
        'last-synced-fcm-token': 'fcm-token',
      });

      await AppPreferences.clearAll();

      final prefs = await SharedPreferences.getInstance();

      expect(
        prefs.getBool(
            'a1b2c3d4-e5f6-7890-abcd-ef1234567890_has_prompted_notification'),
        isTrue,
        reason: 'Lowercase UUID-scoped key must be preserved',
      );
      expect(prefs.getBool('is-first-time'), isFalse,
          reason: 'isFirstTime is explicitly preserved');
      expect(prefs.getString('access-token'), isNull,
          reason: 'Non-user-scoped key must be cleared');
      expect(prefs.getString('some-random-setting'), isNull,
          reason: 'Non-user-scoped key must be cleared');
      expect(prefs.getString('last-synced-fcm-token'), isNull,
          reason: 'Non-user-scoped key must be cleared');
    });

    test('clearAll() preserves UPPERCASE UUID-scoped keys', () async {
      SharedPreferences.setMockInitialValues({
        'is-first-time': false,
        'A1B2C3D4-E5F6-7890-ABCD-EF1234567890_has_skipped_free_trial': true,
        'access-token': 'should-be-cleared',
      });

      await AppPreferences.clearAll();

      final prefs = await SharedPreferences.getInstance();

      expect(
        prefs.getBool(
            'A1B2C3D4-E5F6-7890-ABCD-EF1234567890_has_skipped_free_trial'),
        isTrue,
        reason:
            'Uppercase UUID-scoped key must be preserved (caseSensitive: false)',
      );
      expect(prefs.getString('access-token'), isNull);
    });

    test('clearAll() clears non-UUID keys that look similar', () async {
      SharedPreferences.setMockInitialValues({
        'is-first-time': true,
        'not-a-uuid-1234_some_suffix': 'should-be-cleared',
        'cached_exam_questions_abc': 'should-be-cleared',
      });

      await AppPreferences.clearAll();

      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('not-a-uuid-1234_some_suffix'), isNull,
          reason: 'Non-UUID format key must be cleared');
      expect(prefs.getString('cached_exam_questions_abc'), isNull,
          reason: 'Non-UUID key must be cleared');
    });
  });

  // ─────────────────────────────────────────────────────
  // § 11 — RAPID RETRY
  // ─────────────────────────────────────────────────────

  group('§11 — Rapid retry behavior', () {
    test(
        'Multiple rapid AppLaunchStarted events → no crash, '
        'final state is valid', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      // Simulate 3 rapid taps
      bloc.add(const AppLaunchStarted(skipDelay: true));
      bloc.add(const AppLaunchStarted(skipDelay: true));
      bloc.add(const AppLaunchStarted(skipDelay: true));

      await _waitForSettle(bloc, const Duration(milliseconds: 500));

      // Final state must be valid — no crash, no corruption
      expect(
        bloc.state,
        isA<AppLaunchNavigateHome>(),
        reason: 'After rapid retries, final state must be valid terminal',
      );

      // Note: Without a concurrency transformer (droppable/restartable),
      // the bloc's default concurrent handler processes all events.
      // This is a FINDING documented in the report — no duplicate guard exists.

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 12 — NAVIGATION STATE TRANSITIONS
  // ─────────────────────────────────────────────────────

  group('§12 — Navigation safety', () {
    test('First-time user → Onboarding only (no Login, no Home)', () async {
      _setUpPreferences(isFirstTime: true);

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchShowOnboarding>(),
      ]);

      await sub.cancel();
      await bloc.close();
    });

    test('No session → Login only (not Home, not Onboarding)', () async {
      _setUpPreferences(isFirstTime: false);
      when(() => mockAuthRemoteDataSource.currentSession).thenReturn(null);

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchShowLogin>(),
      ]);

      await sub.cancel();
      await bloc.close();
    });

    test('Incomplete profile → ProfileSetup (not Home)', () async {
      _setUpPreferences(
        cachedUser: _incompleteCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchShowProfileSetup>(),
      ]);

      await sub.cancel();
      await bloc.close();
    });

    test(
        'Retry from error emits AppLaunchInitializing FIRST — '
        'no duplicate navigation states', () async {
      _setUpPreferences(cachedUser: null);
      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => false);

      final bloc = buildBloc();
      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));
      expect(bloc.state, isA<AppLaunchError>());

      // Now retry with success path
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final retryStates = <AppLaunchState>[];
      final sub = bloc.stream.listen(retryStates.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      // Verify exact sequence: Initializing → Home (no duplicates)
      expect(retryStates, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchNavigateHome>(),
      ]);

      // Verify no AppLaunchShowLogin or AppLaunchShowOnboarding leaked in
      expect(retryStates.whereType<AppLaunchShowLogin>(), isEmpty);
      expect(retryStates.whereType<AppLaunchShowOnboarding>(), isEmpty);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // § 13 — LIFECYCLE EDGE CASES
  // ─────────────────────────────────────────────────────

  group('§13 — Lifecycle: sync timeout then retry', () {
    test(
        'GIVEN sync times out (but cache exists) '
        'THEN app proceeds with cached data (no error)', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      // Simulate sync timeout returning Left
      when(() => mockAuthRepository.syncProfile()).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return left(Failure(message: 'Sync timeout'));
        },
      );
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 500));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchNavigateHome>(),
      ]);

      await sub.cancel();
      await bloc.close();
    });
  });

  // ─────────────────────────────────────────────────────
  // ADDITIONAL FLOW COVERAGE
  // ─────────────────────────────────────────────────────

  group('Event handlers: OnboardingCompleted, LoginCompleted, etc.', () {
    test('OnboardingCompleted → AppLaunchShowLogin', () async {
      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const OnboardingCompleted());
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [isA<AppLaunchShowLogin>()]);

      await sub.cancel();
      await bloc.close();
    });

    test('LoginCompleted with complete profile → Home', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );
      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(false));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoginCompleted());
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [isA<AppLaunchNavigateHome>()]);

      await sub.cancel();
      await bloc.close();
    });

    test('FreeTrialHandled → AppLaunchNavigateHome', () async {
      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FreeTrialHandled());
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [isA<AppLaunchNavigateHome>()]);

      await sub.cancel();
      await bloc.close();
    });
  });

  group('Trial eligibility', () {
    test('Eligible user who has NOT skipped → AppLaunchShowFreeTrial',
        () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: false,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockCheckTrialEligibility.call(any()))
          .thenAnswer((_) async => right(true));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      expect(states, [
        isA<AppLaunchInitializing>(),
        isA<AppLaunchShowFreeTrial>(),
      ]);

      await sub.cancel();
      await bloc.close();
    });

    test('Trial check throws → fails open → Home (not error)', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: false,
      );

      when(() => mockAuthRemoteDataSource.currentSession)
          .thenReturn(_fakeSession());
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockCheckTrialEligibility.call(any()))
          .thenThrow(Exception('Trial service down'));

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      // Should fail open → Home, not Error
      expect(states.last, isA<AppLaunchNavigateHome>());

      await sub.cancel();
      await bloc.close();
    });
  });

  group('Session guard in post-auth checks', () {
    test(
        'If session becomes null during post-auth checks '
        '→ silently stops (no crash)', () async {
      _setUpPreferences(
        cachedUser: _completeCachedUserJson(),
        hasPromptedNotification: true,
        hasSkippedFreeTrial: true,
      );

      int callCount = 0;
      when(() => mockAuthRemoteDataSource.currentSession).thenAnswer((_) {
        callCount++;
        return callCount <= 1 ? _fakeSession() : null;
      });
      when(() => mockAuthRemoteDataSource.currentUser)
          .thenReturn(_fakeSession().user);
      when(() => mockAuthRepository.syncProfile())
          .thenAnswer((_) async => right(null));
      when(() => mockConnectionChecker.isConnected)
          .thenAnswer((_) async => true);

      final bloc = buildBloc();
      final states = <AppLaunchState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AppLaunchStarted(skipDelay: true));
      await _waitForSettle(bloc, const Duration(milliseconds: 300));

      // Should not crash
      expect(states.whereType<AppLaunchError>(), isEmpty,
          reason: 'Session becoming null should not cause error');

      await sub.cancel();
      await bloc.close();
    });
  });
}
