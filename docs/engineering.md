# TargetAce: Engineering Architecture, Guidelines & Folder Structure

---

## 🏗️ 1. Clean Architecture Overview

TargetAce follows strict **Clean Architecture** principles to separate business logic, data persistence, and UI presentation:

```text
               +----------------------------------+
               |        Presentation Layer        |
               | (Pages, Widgets, BLoC / Cubit)   |
               +----------------------------------+
                                |
                                v
               +----------------------------------+
               |           Domain Layer           |
               | (Entities, UseCases, Interfaces) |
               +----------------------------------+
                                ^
                                |
               +----------------------------------+
               |            Data Layer            |
               | (Models, DataSources, Repos)     |
               +----------------------------------+
```

### Layer Rules
1. **Domain Layer (`domain/`)**:
   - Contains pure Dart code only. 
   - **Zero dependencies** on Flutter UI, Supabase SDK, or third-party packages (except functional `fpdart` for `Either<Failure, T>`).
   - Defines abstract repository interfaces and business UseCases.
2. **Data Layer (`data/`)**:
   - Implements Domain repository interfaces.
   - Handles remote API communication (`SupabaseClient`), RPC calls, and local storage (`UserLocalDataSource`).
   - Converts API JSON maps into Domain Entities via Data Models (`ExamModel`, `QuestionModel`).
3. **Presentation Layer (`presentation/`)**:
   - Manages UI widgets, layout rendering, and user input events.
   - Uses `flutter_bloc` (`Bloc` / `Cubit`) for reactive state management.
   - Depends only on Domain UseCases (never calls Data Sources directly).

---

## 📁 2. Complete Codebase Directory Sitemap

```text
lib/
├── main.dart                       # App entry point & initialization
│
├── core/                           # Shared core framework
│   ├── common/
│   │   ├── entities/               # Shared Domain Entities (CachedUserEntity)
│   │   └── models/                 # Shared Data Models (CachedUserModel)
│   ├── components/                 # Standard UI Components
│   │   ├── back_button.dart
│   │   ├── custom_container.dart
│   │   ├── custom_divider.dart
│   │   ├── custom_icon_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── filter_field.dart
│   │   ├── info_row.dart
│   │   ├── info_value_item.dart
│   │   ├── premium_avatar_ring.dart
│   │   └── spring_button.dart
│   ├── config/
│   │   ├── app_config.dart         # Global app constants & WhatsApp URLs
│   │   ├── assets.dart             # Image/SVG asset paths
│   │   ├── colors.dart             # Dark Obsidian palette tokens
│   │   ├── messages.dart           # User-facing text strings
│   │   └── typography.dart         # Mandatory AppFonts typography wrapper
│   ├── error/
│   │   ├── failure.dart            # Domain Failure class with ErrorType enum
│   │   └── server_exception.dart   # Data layer Exception class
│   ├── logger/
│   │   └── app_logger.dart         # AppLogger utility wrapper
│   ├── network/
│   │   ├── base_remote_datasource.dart # Base class handling Supabase exceptions
│   │   └── connection_checker.dart     # Interface for internet connection checks
│   ├── services/
│   │   ├── service_locator.dart    # GetIt Dependency Injection container
│   │   └── user_local_datasource.dart # SharedPreferences JSON blob cache
│   ├── shared/
│   │   ├── pages/                  # Shared screens (UnderDevelopmentPage)
│   │   ├── themes/                 # ThemeData, Button themes, Input decoration
│   │   └── widgets/                # AppNotifier, Loader, ErrorStateWidget, etc.
│   ├── usecase/
│   │   └── usecase.dart            # Abstract base UseCase class
│   └── utils/
│       ├── enums/                  # ErrorType, MessageType, etc.
│       └── helpers/                # DateFormatter, DeviceInfoHelper, GreetingHelper
│
└── features/                       # Modular Feature Modules
    ├── auth/
    │   └── presentation/pages/     # SplashPage, LoginPage, OnboardingPage
    ├── battle/
    │   ├── data/
    │   │   ├── datasources/        # BattleRemoteDataSourceImpl (Supabase RPCs)
    │   │   ├── models/             # ExamModel, ExamSubmissionModel
    │   │   └── repositories/       # BattleRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/           # ExamEntity, LeaderboardEntryEntity, LeaderboardDataEntity
    │   │   ├── repository/         # BattleRepository (Interface)
    │   │   ├── services/           # BattleScoreCalculator (Pure Domain Calculation)
    │   │   └── usecases/           # GetExams, SubmitExam, GetExamQuestions, etc.
    │   └── presentation/
    │       ├── bloc/battle/        # BattleBloc, BattleEvent, BattleState
    │       ├── pages/              # BattleHubPage, ExamPage, ExamReviewPage
    │       └── widgets/            # BattleScoreboardView, ExamTimerWidget
    ├── dashboard/
    │   ├── presentation/
    │   │   ├── bloc/               # DashboardBloc, DashboardEvent, DashboardState
    │   │   ├── pages/              # DashboardPage
    │   │   └── widgets/            # DashboardAppBar, PodiumWidget, DashboardStatTile
    ├── notification/
    │   └── presentation/pages/     # NotificationPage
    ├── practice/
    │   ├── data/                   # Practice Data Sources & Repositories
    │   ├── domain/                 # QuestionEntity, SubjectEntity, TopicEntity
    │   └── presentation/
    │       ├── bloc/               # PracticeHubCubit, PracticeSessionCubit
    │       ├── pages/              # PracticeHubPage, PracticePage, SubjectPracticePage
    │       └── widgets/            # QuestionPracticeView, TopicFilterChips
    ├── profile/
    │   └── presentation/pages/     # ProfilePage
    └── subscription/
        ├── presentation/
        │   ├── bloc/               # SubscriptionBloc
        │   └── pages/              # SubscriptionActivationPage
```

---

## 💉 3. Dependency Injection Container (`service_locator.dart`)

All singletons, use cases, repositories, and BLoC factories are registered in `lib/core/services/service_locator.dart` via `GetIt`:

```dart
final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. External & Core
  final supabaseClient = Supabase.instance.client;
  sl.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  // 2. Data Sources
  sl.registerLazySingleton<BattleRemoteDataSource>(
    () => BattleRemoteDataSourceImpl(sl()),
  );

  // 3. Repositories
  sl.registerLazySingleton<BattleRepository>(
    () => BattleRepositoryImpl(remoteDataSource: sl()),
  );

  // 4. Use Cases
  sl.registerLazySingleton(() => GetExams(sl()));
  sl.registerLazySingleton(() => CheckSubmission(sl()));
  sl.registerLazySingleton(() => GetExamQuestions(sl()));
  sl.registerLazySingleton(() => SubmitExam(sl()));
  sl.registerLazySingleton(() => GetLeaderboardAndRanks(sl()));
  sl.registerLazySingleton(() => CalculateBattleScore());

  // 5. BLoCs / Cubits (Factory for fresh instances per page)
  sl.registerFactory(() => BattleBloc(
        getExams: sl(),
        checkSubmission: sl(),
        getExamQuestions: sl(),
        submitExam: sl(),
        getLeaderboardAndRanks: sl(),
        calculateBattleScore: sl(),
      ));
}
```

---

## 📜 4. Coding Conventions & Best Practices

1. **Immutability**: All BLoC States and Domain Entities must be annotated with `const` constructors and immutable fields.
2. **Error Handling**: Data sources throw `ServerException(message: ...)`. Repositories catch exceptions and return `Either<Failure, T>` using `fpdart` (`Left(ServerFailure(...))` or `Right(data)`).
3. **No Dynamic Maps in UI**: UI components must consume strongly typed Domain Entities (e.g. `ExamEntity`, `QuestionEntity`), never raw `Map<String, dynamic>`.
