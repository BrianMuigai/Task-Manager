import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/domain/usecases/reset_password.dart';
import 'package:task/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:task/features/auth/domain/usecases/sign_in_with_google.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithEmailPassword signInWithEmailPassword;
  final ResetPassword resetPassword;
  final FirebaseAuth firebaseAuth;

  AuthBloc(
    this.signInWithGoogle,
    @Named('firebaseAuth') this.firebaseAuth,
    this.signInWithEmailPassword,
    this.resetPassword,
  ) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      // Check if a user is already signed in.
      if (firebaseAuth.currentUser != null) {
        final user = firebaseAuth.currentUser!;
        // Convert Firebase User to our AppUser.
        final appUser = AppUser(
          uid: user.uid,
          displayName: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
        );
        emit(Authenticated(appUser));
      } else {
        emit(Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInWithGoogle();
        emit(Authenticated(user));
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<EmailSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInWithEmailPassword(event.email, event.password);
        emit(Authenticated(user));
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await firebaseAuth.signOut();
      emit(Unauthenticated());
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await resetPassword(event.email);
        emit(PasswordResetEmailSent());
      } catch (e) {
        emit(PasswordResetError(e.toString()));
      }
    });
  }
}
