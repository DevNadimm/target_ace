abstract class CrudService {
  /// Initialize authorization state or token if necessary.
  Future<void> initAuthToken([String? token]);

  /// Set the auth token/session.
  void setAuthToken(String token);

  /// Clear auth token/session.
  void clearAuthToken();

  /// Create (Insert)
  Future<dynamic> create(
    String endpointOrTable,
    dynamic data, {
    Map<String, dynamic>? headers,
    String? errorMessage,
  });

  /// Read (Select/Get)
  Future<dynamic> read(
    String endpointOrTable, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? errorMessage,
  });

  /// Update (Put/Patch)
  Future<dynamic> update(
    String endpointOrTable,
    dynamic data, {
    Map<String, dynamic>? headers,
    bool isPatch = false,
    String? errorMessage,
  });

  /// Delete (Destroy)
  Future<dynamic> delete(
    String endpointOrTable, {
    dynamic data,
    Map<String, dynamic>? headers,
    String? errorMessage,
  });
}
