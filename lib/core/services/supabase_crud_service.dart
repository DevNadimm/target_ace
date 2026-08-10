import 'package:target_ace/core/services/crud_service.dart';
import 'package:target_ace/core/network/base_remote_datasource.dart';
import 'package:target_ace/core/error/server_exception.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';

class SupabaseCrudService extends BaseRemoteDataSource implements CrudService {
  SupabaseCrudService(super.client);

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
    client.auth.signOut();
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
      final response = await client.from(table).insert(data).select();
      return response;
    } catch (e) {
      handleException(e, defaultMessage: errorMessage);
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
      var query = client.from(table).select();

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
      handleException(e, defaultMessage: errorMessage);
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
        throw ServerException(
          message: "Update operation requires an 'id' field in the data payload.",
          type: ErrorType.unknown,
        );
      }
      final response = await client.from(table).update(data).eq('id', id).select();
      return response;
    } catch (e) {
      handleException(e, defaultMessage: errorMessage);
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
        throw ServerException(
          message: "Delete operation requires an 'id' payload or value.",
          type: ErrorType.unknown,
        );
      }
      final response = await client.from(table).delete().eq('id', id).select();
      return response;
    } catch (e) {
      handleException(e, defaultMessage: errorMessage);
    }
  }
}