import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';

/// Base interface for all use cases in the application.
///
/// Every use case implements this interface, ensuring a consistent
/// contract across the domain layer. The `call()` method returns
/// `Either<Failure, SuccessType>` â€” Left for errors, Right for success.
///
/// Usage:
/// ```dart
/// class GetCurrentUser implements UseCase<User, NoParams> {
///   final AuthRepository repository;
///   const GetCurrentUser(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(NoParams params) async {
///     return await repository.currentUser();
///   }
/// }
/// ```
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

/// Marker class for use cases that don't require parameters.
///
/// Example:
/// ```dart
/// final result = await getCurrentUser(NoParams());
/// ```
class NoParams {
  const NoParams();
}