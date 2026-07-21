import 'package:target_ace/core/services/crud_service.dart';
import 'package:target_ace/core/services/dio_service.dart';

class DioCrudService implements CrudService {
  final DioService _dioService;

  DioCrudService(this._dioService);

  @override
  Future<void> initAuthToken([String? token]) => _dioService.initAuthToken(token);

  @override
  void setAuthToken(String token) => _dioService.setAuthToken(token);

  @override
  void clearAuthToken() => _dioService.clearAuthToken();

  @override
  Future<dynamic> create(
    String endpointOrTable,
    dynamic data, {
    Map<String, dynamic>? headers,
    String? errorMessage,
  }) async {
    final response = await _dioService.postRequest(
      endpointOrTable,
      data: data,
      headers: headers,
      errorMessage: errorMessage,
    );
    return response.data;
  }

  @override
  Future<dynamic> read(
    String endpointOrTable, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? errorMessage,
  }) async {
    final response = await _dioService.getRequest(
      endpointOrTable,
      queryParameters: queryParameters,
      headers: headers,
      errorMessage: errorMessage,
    );
    return response.data;
  }

  @override
  Future<dynamic> update(
    String endpointOrTable,
    dynamic data, {
    Map<String, dynamic>? headers,
    bool isPatch = false,
    String? errorMessage,
  }) async {
    final response = isPatch
        ? await _dioService.patchRequest(
            endpointOrTable,
            data: data,
            headers: headers,
            errorMessage: errorMessage,
          )
        : await _dioService.putRequest(
            endpointOrTable,
            data: data,
            headers: headers,
            errorMessage: errorMessage,
          );
    return response.data;
  }

  @override
  Future<dynamic> delete(
    String endpointOrTable, {
    dynamic data,
    Map<String, dynamic>? headers,
    String? errorMessage,
  }) async {
    final response = await _dioService.deleteRequest(
      endpointOrTable,
      data: data,
      headers: headers,
      errorMessage: errorMessage,
    );
    return response.data;
  }
}
