import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:target_ace/core/config/api_endpoints.dart';
import 'package:target_ace/core/config/messages.dart';
import 'package:target_ace/core/exceptions/api_exception.dart';
import 'package:target_ace/core/logger/app_logger.dart';
import 'package:target_ace/core/logger/dio_logger_interceptor.dart';
import 'package:target_ace/core/services/app_preferences.dart';
import 'package:target_ace/core/utils/enums/error_type.dart';
import 'package:target_ace/features/auth/presentation/pages/login_page.dart';
import 'package:target_ace/features/subscription/presentation/pages/subscription_expired_page.dart';
import 'package:target_ace/main.dart';

class DioService {
  final Dio _dio;

  DioService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiEndpoints.apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.addAll([DioLoggerInterceptor(), _authErrorInterceptor()]);
  }

  // â”€â”€â”€ Auth â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Call once at app startup to restore saved token.
  Future<void> initAuthToken([String? token]) async {
    final authToken = (token?.isNotEmpty ?? false) ? token! : await AppPreferences.getAccessToken();

    if (authToken.isNotEmpty) {
      setAuthToken(authToken);
    }
  }

  void setAuthToken(String token) => _dio.options.headers['Authorization'] = 'Bearer $token';

  void clearAuthToken() => _dio.options.headers.remove('Authorization');

  // â”€â”€â”€ Interceptors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  InterceptorsWrapper _authErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        if (e.response?.statusCode == 401) {
          AppLogger.w('401 Unauthorized â€” clearing session & redirecting.');
          clearAuthToken();
          await AppPreferences.clearAll();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false,
          );
        } else if (e.response?.statusCode == 402) {
          AppLogger.w('402 Subscription expired - redirecting');
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SubscriptionExpiredPage()), (_) => false,
          );
        }
        handler.next(e);
      },
    );
  }

  // â”€â”€â”€ Error Handling â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Priority:
  ///   1. Backend message  â†’ preserves ErrorType from status code
  ///   2. DioExceptionType â†’ maps to network / server / etc.
  ///   3. fallbackMessage  â†’ caller-supplied
  ///   4. Generic message
  ApiException _handleError(DioException e, {String? fallbackMessage}) {
    final statusCode = e.response?.statusCode;

    // Resolve ErrorType from status code first so backend messages
    // don't get mislabeled as ErrorType.server on a 404, etc.
    final errorType = _errorTypeFromStatus(statusCode);

    // 1. Try backend message â€” keeps correct ErrorType from status code
    final backendMessage = _extractBackendMessage(e.response?.data);
    if (backendMessage != null) {
      return ApiException(message: backendMessage, type: errorType);
    }

    // 2. Map by DioExceptionType
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiException(
        message: AppMessages.timeoutErrorMessage,
        type: ErrorType.network,
      ),

      DioExceptionType.connectionError => ApiException(
        message: AppMessages.networkErrorMessage,
        type: ErrorType.network,
      ),

      DioExceptionType.badResponse => ApiException(
        message: _messageFromStatus(statusCode),
        type: errorType,
      ),

      DioExceptionType.cancel => ApiException(
        message: AppMessages.requestCancelledMessage,
        type: ErrorType.unknown,
      ),

      _ => ApiException(
        message: fallbackMessage ?? AppMessages.errorMessage,
        type: ErrorType.unknown,
      ),
    };
  }

  /// Maps HTTP status code â†’ ErrorType.
  ErrorType _errorTypeFromStatus(int? statusCode) {
    if (statusCode == null) return ErrorType.unknown;
    return switch (statusCode) {
      404 => ErrorType.notFound,
      401 || 403 => ErrorType.server,
      >= 500 => ErrorType.server,
      _ => ErrorType.unknown,
    };
  }

  /// Maps HTTP status code â†’ user-facing message.
  String _messageFromStatus(int? statusCode) {
    if (statusCode == null) return AppMessages.errorMessage;
    return switch (statusCode) {
      404 => AppMessages.notFoundErrorMessage,
      401 => AppMessages.sessionExpiredMessage,
      403 => AppMessages.forbiddenErrorMessage,
      >= 500 => AppMessages.serverErrorMessage,
      _ => AppMessages.errorMessage,
    };
  }

  /// Extracts error message from backend response.
  /// Handles common patterns:
  ///   { "message": "..." }
  ///   { "error": "..." }
  ///   { "errors": ["...", ...] }
  ///   { "errors": [{ "message": "..." }, ...] }
  String? _extractBackendMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final direct = data['message'] ?? data['error'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();

    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
      if (first is Map<String, dynamic>) {
        final msg = first['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty) return msg;
      }
    }

    return null;
  }

  // â”€â”€â”€ Bot-Protection Detection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Imunify360 / WAF bot-protection returns HTTP 200 with a plain-text or
  /// JSON body containing a specific message. We detect it here so callers
  /// always receive a proper [ApiException] instead of silently bad data.
  bool _isBotProtectionResponse(Response response) {
    final data = response.data;
    String? message;

    if (data is Map<String, dynamic>) {
      message = data['message']?.toString();
    } else if (data is String) {
      message = data;
    }

    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower.contains('imunify360') || lower.contains('bot-protection') || lower.contains('access denied by imunify');
  }

  // â”€â”€â”€ Core Executor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Response> _execute(
    Future<Response> Function() call, {
    String? errorMessage,
  }) async {
    try {
      final response = await call();

      // Imunify360 bot-protection returns 200 with an error message body.
      // Treat it as a server error so callers always get an ApiException.
      if (_isBotProtectionResponse(response)) {
        AppLogger.w('Bot-protection block detected (HTTP 200 spoofed as success).');
        throw ApiException(
          title: AppMessages.botProtectionErrorTitle,
          message: AppMessages.botProtectionErrorMessage,
          type: ErrorType.botProtection,
        );
      }

      return response;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _handleError(e, fallbackMessage: errorMessage);
    }
  }

  // â”€â”€â”€ HTTP Methods â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Response> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers, // âœ… per-request headers
    CancelToken? cancelToken, // âœ… cancellation support
    String? errorMessage,
  }) => _execute(
    () => _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: Options(headers: headers ?? _dio.options.headers),
      cancelToken: cancelToken,
    ),
    errorMessage: errorMessage,
  );

  Future<Response> postRequest(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    String? errorMessage,
  }) => _execute(
    () => _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers ?? _dio.options.headers),
      cancelToken: cancelToken,
    ),
    errorMessage: errorMessage,
  );

  Future<Response> putRequest(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    String? errorMessage,
  }) => _execute(
    () => _dio.put(
      endpoint,
      data: data,
      options: Options(headers: headers ?? _dio.options.headers),
      cancelToken: cancelToken,
    ),
    errorMessage: errorMessage,
  );

  Future<Response> patchRequest(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    String? errorMessage,
  }) => _execute(
    () => _dio.patch(
      endpoint,
      data: data,
      options: Options(headers: headers ?? _dio.options.headers),
      cancelToken: cancelToken,
    ),
    errorMessage: errorMessage,
  );

  Future<Response> deleteRequest(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    String? errorMessage,
  }) => _execute(
    () => _dio.delete(
      endpoint,
      data: data,
      options: Options(headers: headers ?? _dio.options.headers),
      cancelToken: cancelToken,
    ),
    errorMessage: errorMessage,
  );

  // â”€â”€â”€ Multipart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<Response> postMultipart(String endpoint, {
    File? file,
    String? fileFieldName,
    List<File>? files,
    String? filesFieldName,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    String? errorMessage,
  }) async {
    final formMap = await _buildFormMap(
      data: data,
      file: file,
      fileFieldName: fileFieldName,
      files: files,
      filesFieldName: filesFieldName,
    );
    return _execute(
      () => _dio.post(
        endpoint,
        data: FormData.fromMap(formMap),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      errorMessage: errorMessage,
    );
  }

  Future<Response> putMultipart(String endpoint, {
    File? file,
    String? fileFieldName,
    List<File>? files,
    String? filesFieldName,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    String? errorMessage,
  }) async {
    final formMap = await _buildFormMap(
      data: data,
      file: file,
      fileFieldName: fileFieldName,
      files: files,
      filesFieldName: filesFieldName,
    );
    return _execute(
      () => _dio.put(
        endpoint,
        data: FormData.fromMap(formMap),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      errorMessage: errorMessage,
    );
  }

  /// Shared FormData builder for all multipart methods.
  /// Files are processed in parallel via Future.wait for performance.
  Future<Map<String, dynamic>> _buildFormMap({
    Map<String, dynamic>? data,
    File? file,
    String? fileFieldName,
    List<File>? files,
    String? filesFieldName,
  }) async {
    final formMap = <String, dynamic>{...?data};

    if (file != null && fileFieldName != null) {
      formMap[fileFieldName] = await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      );
    }

    if (files != null && files.isNotEmpty && filesFieldName != null) {
      formMap['$filesFieldName[]'] = await Future.wait(
        files.map((f) => MultipartFile.fromFile(f.path, filename: f.uri.pathSegments.last)),
      );
    }

    return formMap;
  }
}

