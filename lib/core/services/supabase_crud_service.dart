import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:target_ace/core/services/crud_service.dart';
import 'package:target_ace/core/exceptions/api_exception.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

class SupabaseCrudService implements CrudService {
  final SupabaseClient _client;

  SupabaseCrudService(this._client);

  @override
  Future<void> initAuthToken([String? token]) async {
    // Supabase client manages persistence and session lifecycle automatically.
  }

  @override
  void setAuthToken(String token) {
    // Session token JWT is managed internally by Supabase client's auth header or session state.
  }

  @override
  void clearAuthToken() {
    _client.auth.signOut();
  }

  /// Maps REST API path/endpoints to database table names.
  /// Example: "/api/properties" or "properties" -> "properties"
  String _toTableName(String path) {
    var clean = path;
    if (clean.startsWith('/')) {
      clean = clean.substring(1);
    }
    if (clean.startsWith('api/')) {
      clean = clean.substring(4);
    }
    final segments = clean.split('/');
    return segments.isEmpty ? clean : segments.first;
  }

  @override
  Future<dynamic> create(
    String endpointOrTable,
    dynamic data, {
    Map<String, dynamic>? headers,
    String? errorMessage,
  }) async {
    try {
      final table = _toTableName(endpointOrTable);
      final response = await _client.from(table).insert(data).select();
      return response;
    } catch (e) {
      throw ApiException(
        message: errorMessage ?? e.toString(),
        type: ErrorType.server,
      );
    }
  }

  @override
  Future<dynamic> read(
    String endpointOrTable, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? errorMessage,
  }) async {
    try {
      final table = _toTableName(endpointOrTable);
      var query = _client.from(table).select();

      if (queryParameters != null) {
        queryParameters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      final response = await query;
      return response;
    } catch (e) {
      throw ApiException(
        message: errorMessage ?? e.toString(),
        type: ErrorType.server,
      );
    }
  }

  @override
  Future<dynamic> update(
    String endpointOrTable,
    dynamic data, {
    Map<String, dynamic>? headers,
    bool isPatch = false,
    String? errorMessage,
  }) async {
    try {
      final table = _toTableName(endpointOrTable);
      final id = data is Map ? data['id'] : null;
      if (id == null) {
        throw ApiException(
          message: "Update operation requires an 'id' field in the data payload.",
          type: ErrorType.unknown,
        );
      }
      final response = await _client.from(table).update(data).eq('id', id).select();
      return response;
    } catch (e) {
      throw ApiException(
        message: errorMessage ?? e.toString(),
        type: ErrorType.server,
      );
    }
  }

  @override
  Future<dynamic> delete(
    String endpointOrTable, {
    dynamic data,
    Map<String, dynamic>? headers,
    String? errorMessage,
  }) async {
    try {
      final table = _toTableName(endpointOrTable);
      final id = data is Map ? data['id'] : data;
      if (id == null) {
        throw ApiException(
          message: "Delete operation requires an 'id' payload or value.",
          type: ErrorType.unknown,
        );
      }
      final response = await _client.from(table).delete().eq('id', id).select();
      return response;
    } catch (e) {
      throw ApiException(
        message: errorMessage ?? e.toString(),
        type: ErrorType.server,
      );
    }
  }
}
