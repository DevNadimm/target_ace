part of 'auth_bloc.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthModel authModel;
  AuthSuccess(this.authModel);
}

class AuthFailure extends AuthState {
  final ErrorType? errorType;
  final String? message;
  AuthFailure(this.errorType, this.message);
}

class LogoutSuccess extends AuthState {}

