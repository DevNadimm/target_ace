import 'package:target_ace/core/utils/enums/error_type.dart';

/// Data-layer exception thrown by DataSource/Service implementations.
///
/// Implements [Exception] and contains structured data about the failure.
/// Replaces the legacy `ApiException` to align with Clean Architecture.
///
/// Example:
/// ```dart
/// throw ServerException(
///   message: "Failed to connect to the server",
///   type: ErrorType.network,
/// );
/// ```
class ServerException implements Exception {
  final String? title;
  final String message;
  final ErrorType type;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.title,
    this.type = ErrorType.unknown,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (type: $type, statusCode: $statusCode)';
}
