import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

abstract class BaseRemoteDataSource {
  final SupabaseClient client;

  const BaseRemoteDataSource(this.client);

  /// Handles Supabase exceptions, specifically catching authentication failures 
  /// (PGRST301 or HTTP 401), timeouts, socket errors, and synchronizing the local SDK session state.
  Never handleException(Object e, {String? defaultMessage}) {
    final errorString = e.toString().toLowerCase();
    
    // Catch timeout exceptions
    if (e is TimeoutException ||
        errorString.contains('timeoutexception') ||
        errorString.contains('timed out') ||
        errorString.contains('deadline exceeded')) {
      throw const ServerException(
        message: AppMessages.timeoutErrorMessage,
        type: ErrorType.network,
      );
    }

    // Catch underlying HTTP client/socket exceptions (e.g. offline device, wifi off)
    if (e is SocketException ||
        errorString.contains('socketexception') || 
        (errorString.contains('clientexception') && errorString.contains('failed host lookup')) ||
        errorString.contains('network is unreachable') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection reset') ||
        errorString.contains('connection closed') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('software caused connection abort')) {
      throw const ServerException(
        message: AppMessages.networkErrorMessage,
        type: ErrorType.network,
      );
    }

    if (e is PostgrestException) {
      if (e.code == 'PGRST301' || e.code == '401' || e.message.contains('User profile not found')) {
        // Only sign out the SDK session for genuine authentication rejections
        // (expired JWT, invalid/revoked token). Do NOT sign out for other
        // Postgres errors that happen to hit this branch (e.g. missing profile row).
        final msg = e.message.toLowerCase();
        final isAuthRejection = msg.contains('jwt') ||
            msg.contains('expired') ||
            msg.contains('invalid') ||
            msg.contains('token') ||
            msg.contains('not authorized') ||
            e.code == '401';
        if (isAuthRejection) {
          client.auth.signOut();
        }
        
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
