import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/api_endpoints.dart';
import 'package:target_ace/core/services/crud_service.dart';
import 'package:target_ace/core/services/supabase_crud_service.dart';
// import 'package:target_ace/core/services/dio_crud_service.dart';
import 'dio_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:target_ace/features/auth/data/repos/auth_repo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _registerCore();
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
    // For future dedicated backend migration, swap with:
    // return DioCrudService(sl<DioService>());
  });

  sl.registerLazySingleton(() => ApiEndpoints());

  // Register AuthRepo singleton
  sl.registerLazySingleton<AuthRepo>(() => AuthRepo(
        client: sl<SupabaseClient>(),
        googleSignIn: sl<GoogleSignIn>(),
      ));
}

/// Usage inside Repository:
/// final DioService _dio = getIt<DioService>();
/// âœ… The same instance will always be used across the app.

/// When login succeeds and the token is set, all repositories will use it:
/// getIt<DioService>().setAuthToken(token);
/// âœ… Set once, automatically applied everywhere.

/// On logout:
/// getIt<DioService>().clearAuthToken();
/// âœ… Removes the Authorization header for all future requests.

