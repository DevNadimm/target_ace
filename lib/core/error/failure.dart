import 'package:target_ace/core/utils/enums/error_type.dart';

/// Domain-layer failure class for clean architecture error handling.
///
/// Used as the LEFT side of `Either<Failure, T>` returned by repositories.
/// Unlike exceptions, failures are VALUES that flow through the call stack
/// without try-catch â€” making error handling explicit and type-safe.
///
/// Example:
/// ```dart
/// Future<Either<Failure, User>> login(...) {
///   try {
///     final user = await remoteDataSource.login(...);
///     return right(user);
///   } on ServerException catch (e) {
///     return left(Failure(message: e.message));
///   }
/// }
/// ```
class Failure {
  final String message;
  final String? title;
  final ErrorType type;

  const Failure({
    required this.message,
    this.title,
    this.type = ErrorType.unknown,
  });

  @override
  String toString() => 'Failure(title: $title, message: $message, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure && runtimeType == other.runtimeType && message == other.message && title == other.title && type == other.type;

  @override
  int get hashCode => message.hashCode ^ title.hashCode ^ type.hashCode;
}