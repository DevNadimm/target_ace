import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ âž¡ï¸  REQUEST â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€')
        ..writeln('â”‚ METHOD  : ${options.method}')
        ..writeln('â”‚ URL     : ${options.uri}')
        ..writeln('â”‚ HEADERS : ${options.headers}');

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('â”‚ QUERY   : ${options.queryParameters}');
      }
      if (options.data != null) {
        buffer.writeln('â”‚ BODY    : ${options.data}');
      }

      buffer.write('â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€');
      AppLogger.i(buffer.toString());
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.i(
        'â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ âœ…  RESPONSE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€\n'
        'â”‚ STATUS : ${response.statusCode}\n'
        'â”‚ URL    : ${response.requestOptions.uri}\n'
        'â”‚ DATA   : ${response.data}\n'
        'â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      'â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ âŒ  ERROR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€\n'
      'â”‚ URL     : ${err.requestOptions.uri}\n'
      'â”‚ STATUS  : ${err.response?.statusCode}\n'
      'â”‚ MESSAGE : ${err.message}\n'
      'â”‚ DATA    : ${err.response?.data}\n'
      'â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€',
      err,
      err.stackTrace,
    );

    handler.next(err);
  }
}
