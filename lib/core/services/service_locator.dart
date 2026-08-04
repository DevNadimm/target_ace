import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:target_ace/core/config/api_endpoints.dart';
import 'package:target_ace/core/network/connection_checker.dart';
import 'package:target_ace/core/services/crud_service.dart';
import 'package:target_ace/core/services/notification_service.dart';
import 'package:target_ace/core/services/supabase_crud_service.dart';
import 'dio_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:target_ace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:target_ace/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:target_ace/features/auth/domain/repository/auth_repository.dart';
import 'package:target_ace/features/auth/domain/usecases/do_google_sign_in.dart';
import 'package:target_ace/features/auth/domain/usecases/do_logout.dart';
import 'package:target_ace/features/auth/domain/usecases/do_sync_profile.dart';
import 'package:target_ace/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:target_ace/features/launch/presentation/bloc/app_launch_bloc.dart';
import 'package:target_ace/features/profile/presentation/bloc/group_switch_cubit.dart';
import 'package:target_ace/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:target_ace/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:target_ace/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:target_ace/features/subscription/domain/repository/subscription_repository.dart';
import 'package:target_ace/features/subscription/domain/usecases/check_trial_eligibility.dart';
import 'package:target_ace/features/subscription/domain/usecases/activate_free_trial.dart';
import 'package:target_ace/features/subscription/domain/usecases/get_subscription_status.dart';
import 'package:target_ace/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:target_ace/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:target_ace/features/profile/domain/repository/profile_repository.dart';
import 'package:target_ace/features/practice/data/datasources/practice_remote_datasource.dart';
import 'package:target_ace/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:target_ace/features/practice/domain/repository/practice_repository.dart';
import 'package:target_ace/features/practice/domain/usecases/get_subjects.dart';
import 'package:target_ace/features/practice/domain/usecases/get_topics.dart';
import 'package:target_ace/features/practice/domain/usecases/get_subject_questions.dart';
import 'package:target_ace/features/practice/presentation/bloc/subjects/practice_subjects_cubit.dart';
import 'package:target_ace/features/practice/presentation/bloc/session/practice_session_cubit.dart';
import 'package:target_ace/features/practice/presentation/bloc/hub/practice_hub_cubit.dart';
import 'package:target_ace/features/practice/presentation/bloc/bookmarks/bookmarked_questions_cubit.dart';
import 'package:target_ace/features/profile/domain/usecases/do_setup_profile.dart';
import 'package:target_ace/features/profile/domain/usecases/get_battle_groups.dart';
import 'package:target_ace/features/profile/domain/usecases/get_onboarding_goals.dart';
import 'package:target_ace/features/profile/presentation/bloc/setup/profile_setup_cubit.dart';
import 'package:target_ace/features/profile/domain/usecases/get_profile.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_arena_data.dart';
import 'package:target_ace/features/profile/presentation/bloc/profile/profile_cubit.dart';
import 'package:target_ace/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:target_ace/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:target_ace/features/notification/domain/repository/notification_repository.dart';
import 'package:target_ace/features/notification/domain/usecases/get_notifications.dart';
import 'package:target_ace/features/notification/domain/usecases/mark_notification_as_read.dart';
import 'package:target_ace/features/notification/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:target_ace/features/notification/domain/usecases/delete_notification.dart';
import 'package:target_ace/features/notification/domain/usecases/delete_all_notifications.dart';
import 'package:target_ace/features/notification/domain/usecases/store_fcm_token.dart';
import 'package:target_ace/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:target_ace/features/battle/data/datasources/battle_remote_datasource.dart';
import 'package:target_ace/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:target_ace/features/battle/domain/repository/battle_repository.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battles.dart';
import 'package:target_ace/features/battle/domain/usecases/check_submission.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_questions.dart';
import 'package:target_ace/features/battle/domain/usecases/submit_battle.dart';
import 'package:target_ace/features/battle/domain/usecases/calculate_battle_score.dart';
import 'package:target_ace/features/battle/domain/usecases/get_leaderboard_and_ranks.dart';
import 'package:target_ace/features/battle/domain/usecases/get_user_submissions.dart';
import 'package:target_ace/features/battle/domain/usecases/get_group_battles.dart';
import 'package:target_ace/features/battle/domain/usecases/get_battle_leaderboard_data.dart';
import 'package:target_ace/features/battle/domain/usecases/get_leaderboard_cache.dart';
import 'package:target_ace/features/battle/presentation/bloc/battle/battle_bloc.dart';
import 'package:target_ace/features/battle/presentation/bloc/arena/battle_arena_bloc.dart';
import 'package:target_ace/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:target_ace/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:target_ace/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:target_ace/features/dashboard/domain/usecases/get_dashboard.dart';
import 'package:target_ace/features/dashboard/domain/usecases/get_group_leaderboard.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:target_ace/features/dashboard/presentation/bloc/leaderboard/leaderboard_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _registerCore();
  _initAuth();
  _initProfile();
  _initPractice();
  _initNotification();
  _initSubscription();
  _initBattle();
  _initDashboard();
}

Future<void> _registerCore() async {
  // Register base DioService
  sl.registerSingletonAsync<DioService>(() async {
    final service = DioService();
    await service.initAuthToken();
    return service;
  });

  // Register SupabaseClient
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Register GoogleSignIn
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // Register CrudService (defaulted to Supabase, easy to switch to DioCrudService later)
  sl.registerLazySingleton<CrudService>(() {
    return SupabaseCrudService(sl<SupabaseClient>());
  });

  sl.registerLazySingleton(() => ApiEndpoints());

  // Register NotificationService singleton
  sl.registerLazySingleton<NotificationService>(() => NotificationService(
        client: sl<SupabaseClient>(),
        messaging: FirebaseMessaging.instance,
        localNotifications: FlutterLocalNotificationsPlugin(),
      ));

  // Register GroupSwitchCubit factory
  sl.registerFactory(() => GroupSwitchCubit(
        notificationService: sl<NotificationService>(),
        profileRepository: sl<ProfileRepository>(),
        authRemoteDataSource: sl<AuthRemoteDataSource>(),
      ));

  // ── Clean Architecture Core ──

  // Connectivity (for ConnectionChecker)
  sl.registerFactory(() => Connectivity());

  // ConnectionChecker (repository-level network check)
  sl.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(sl()),
  );

  // AppUserCubit (global auth state — single instance)
  sl.registerLazySingleton(() => AppUserCubit());

  // ── Launch Coordinator ──
  sl.registerLazySingleton(
    () => AppLaunchBloc(
      authRemoteDataSource: sl(),
      authRepository: sl(),
      connectionChecker: sl(),
      checkTrialEligibility: sl(),
    ),
  );
}

void _initAuth() {
  sl
    // Datasource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl(), sl(), sl()),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => DoGoogleSignIn(sl()))
    ..registerFactory(() => DoLogout(sl()))
    ..registerFactory(() => DoSyncProfile(sl()))
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        doGoogleSignIn: sl(),
        doLogout: sl(),
        appUserCubit: sl(),
      ),
    );
}

void _initProfile() {
  sl
    // Datasource
    ..registerFactory<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<ProfileRepository>(
      () => ProfileRepositoryImpl(sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => GetOnboardingGoals(sl()))
    ..registerFactory(() => GetBattleGroups(sl()))
    ..registerFactory(() => DoSetupProfile(sl()))
    ..registerFactory(() => GetProfile(sl()))
    // Cubit
    ..registerFactory(
      () => ProfileSetupCubit(
        getOnboardingGoals: sl(),
        getBattleGroups: sl(),
        doSetupProfile: sl(),
      ),
    )
    ..registerFactory(
      () => ProfileCubit(
        getProfile: sl(),
      ),
    );
}

void _initPractice() {
  sl
    // Datasource
    ..registerFactory<PracticeRemoteDataSource>(
      () => PracticeRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<PracticeRepository>(
      () => PracticeRepositoryImpl(sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => GetSubjects(sl()))
    ..registerFactory(() => GetTopics(sl()))
    ..registerFactory(() => GetSubjectQuestions(sl()))
    // Cubits
    ..registerFactory(
      () => PracticeSubjectsCubit(
        getSubjects: sl(),
      ),
    )
    ..registerFactory(
      () => PracticeSessionCubit(
        repository: sl(),
      ),
    )
    ..registerLazySingleton(
      () => PracticeHubCubit(
        repository: sl(),
      ),
    )
    ..registerFactory(
      () => BookmarkedQuestionsCubit(
        repository: sl(),
      ),
    );
}

void _initNotification() {
  sl
    // Datasource
    ..registerFactory<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<NotificationRepository>(
      () => NotificationRepositoryImpl(sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => GetNotifications(sl()))
    ..registerFactory(() => MarkNotificationAsRead(sl()))
    ..registerFactory(() => MarkAllNotificationsAsRead(sl()))
    ..registerFactory(() => DeleteNotification(sl()))
    ..registerFactory(() => DeleteAllNotifications(sl()))
    ..registerFactory(() => StoreFcmToken(sl()))
    // Bloc
    ..registerFactory(
      () => NotificationBloc(
        getNotifications: sl(),
        markNotificationAsRead: sl(),
        markAllNotificationsAsRead: sl(),
        deleteNotification: sl(),
        deleteAllNotifications: sl(),
      ),
    );
}

void _initSubscription() {
  sl
    // Datasource
    ..registerFactory<SubscriptionRemoteDataSource>(
      () => SubscriptionRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl(), sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => GetSubscriptionStatus(sl()))
    ..registerFactory(() => CheckTrialEligibility(sl()))
    ..registerFactory(() => ActivateFreeTrial(sl()))
    // Bloc
    ..registerFactory(
      () => SubscriptionBloc(
        getSubscriptionStatus: sl(),
      ),
    );
}

void _initBattle() {
  sl
    // Datasource
    ..registerFactory<BattleRemoteDataSource>(
      () => BattleRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<BattleRepository>(
      () => BattleRepositoryImpl(sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => GetBattles(sl()))
    ..registerFactory(() => CheckSubmission(sl()))
    ..registerFactory(() => GetGroupBattles(sl()))
    ..registerFactory(() => GetUserSubmissions(sl()))
    ..registerFactory(() => GetBattleArenaData(sl()))
    ..registerFactory(() => GetBattleQuestions(sl()))
    ..registerFactory(() => SubmitBattle(sl()))
    ..registerFactory(() => GetLeaderboardAndRanks(sl()))
    ..registerFactory(() => GetBattleLeaderboardData(sl()))
    ..registerFactory(() => GetLeaderboardCache(sl()))
    ..registerFactory(() => CalculateBattleScore())
    // Cubits & Blocs
    ..registerFactory(
      () => BattleBloc(
        getBattles: sl(),
        checkSubmission: sl(),
        getBattleQuestions: sl(),
        submitBattle: sl(),
        getLeaderboardAndRanks: sl(),
        calculateBattleScore: sl(),
      ),
    )
    ..registerFactory(
      () => BattleArenaBloc(
        getBattleArenaData: sl(),
      ),
    );
}

void _initDashboard() {
  sl
    // Datasource
    ..registerFactory<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<DashboardRepository>(
      () => DashboardRepositoryImpl(sl(), sl()),
    )
    // Use Cases
    ..registerFactory(() => GetDashboard(sl()))
    ..registerFactory(() => GetGroupLeaderboard(sl()))
    // Bloc & Cubit
    ..registerFactory(
      () => DashboardBloc(
        getDashboard: sl(),
      ),
    )
    ..registerFactory(
      () => LeaderboardCubit(
        getGroupLeaderboard: sl(),
      ),
    );
}
