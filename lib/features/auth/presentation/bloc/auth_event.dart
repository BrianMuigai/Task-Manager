part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const EmailSignInRequested({required this.email, required this.password});
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });
}
