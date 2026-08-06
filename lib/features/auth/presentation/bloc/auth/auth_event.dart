part of 'auth_bloc.dart';

sealed class AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class AuthSignedOut extends AuthEvent {}