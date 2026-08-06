import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

abstract class BaseRemoteDataSource {
  final SupabaseClient client;

  const BaseRemoteDataSource(this.client);

  /// Handles Supabase exceptions, specifically catching authentication failures 
  /// (PGRST301 or HTTP 401) and synchronizing the local SDK session state.
  Never handleException(Object e, {String? defaultMessage}) {
    if (e is PostgrestException) {
      if (e.code == 'PGRST301' || e.code == '401' || e.message.contains('User profile not found')) {
        // Infrastructure synchronization: The server rejected the session.
        // We call signOut() to sync the SDK state, which will eventually
        // emit AuthChangeEvent.signedOut.
        client.auth.signOut();
        
        throw ServerException(
          message: e.message,
          type: ErrorType.auth,
        );
      }
      throw ServerException(
        message: e.message,
        type: ErrorType.server,
      );
    } else if (e is AuthException) {
       throw ServerException(
        message: e.message,
        type: ErrorType.auth,
      );
    }

    throw ServerException(
      message: defaultMessage ?? e.toString(),
      type: ErrorType.unknown,
    );
  }
}
