import 'package:fpdart/fpdart.dart';
import 'package:target_ace/core/error/failure.dart';
import 'package:target_ace/features/auth/domain/entities/auth_result.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthResult>> googleSignIn();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> localLogout();
  Future<Either<Failure, void>> syncProfile();
}