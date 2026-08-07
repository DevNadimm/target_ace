import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

abstract class BaseRemoteDataSource {
  final SupabaseClient client;

  const BaseRemoteDataSource(this.client);

  /// Handles Supabase exceptions, specifically catching authentication failures 
  /// (PGRST301 or HTTP 401) and synchronizing the local SDK session state.
  Never handleException(Object e, {String? defaultMessage}) {
    final errorString = e.toString().toLowerCase();
    
    // Catch underlying HTTP client/socket exceptions (e.g. offline device)
    if (errorString.contains('socketexception') || 
        errorString.contains('clientexception') && errorString.contains('failed host lookup')) {
      throw const ServerException(
        message: 'No internet connection. Please check your network.',
        type: ErrorType.network,
      );
    }

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
