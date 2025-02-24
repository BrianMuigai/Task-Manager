import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/app_dialogs.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/auth/presentation/pages/login_page.dart';
import 'package:task/features/tasks/presentation/pages/tasks_list_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          // Show a global success message (e.g., SnackBar)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Password reset email sent! Please check your inbox.")),
          );
        } else if (state is PasswordResetError) {
          showErrorDialog(
              context, "Error sending reset email: ${state.message}");
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state is Authenticated) {
            return TasksListPage();
          } else {
            // Unauthenticated, PasswordResetEmailSent, PasswordResetError, etc.
            // All fall through to show the login page. The BlocListener above
            // will handle the snackbars for reset‐password states.
            return LoginPage();
          }
        },
      ),
    );
  }
}
