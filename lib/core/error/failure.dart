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

  const Failure({
    required this.message,
    this.title,
  });

  @override
  String toString() => 'Failure(title: $title, message: $message)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          title == other.title;

  @override
  int get hashCode => message.hashCode ^ title.hashCode;
}