part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class RegistrationError extends AuthState {
  final String error;

  const RegistrationError({required this.error});
}

class LoginError extends AuthState {
  final String error;

  const LoginError({required this.error});
}

class PasswordResetEmailSent extends AuthState {}

class PasswordResetError extends AuthState {
  final String message;
  const PasswordResetError(this.message);
}
