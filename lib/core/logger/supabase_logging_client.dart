import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:target_ace/core/logger/app_logger.dart';

class SupabaseLoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();
    
    // Log request method and URL
    AppLogger.i('--> Supabase Request: ${request.method} ${request.url}');
    
    try {
      final streamedResponse = await _inner.send(request);
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      // Convert streamed response to standard response to read the body
      final response = await http.Response.fromStream(streamedResponse);

      // Log response status and body
      AppLogger.i('<-- Supabase Response (${duration}ms) [Status ${response.statusCode}]:\n${response.body}');

      // Recreate and return a streamed response from cached bytes
      return http.StreamedResponse(
        Stream.value(response.bodyBytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e, stack) {
      AppLogger.e('Supabase Request Failed', e, stack);
      rethrow;
    }
  }
}
