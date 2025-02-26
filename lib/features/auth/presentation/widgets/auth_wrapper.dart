import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/app_dialogs.dart';
import 'package:task/core/l10n/app_localization.dart';
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
                content: Text(AppLocalizations.getString(
                    context, 'passwordResetEmailSent'))),
          );
        } else if (state is PasswordResetError) {
          showErrorDialog(context,
              "${AppLocalizations.getString(context, 'errorSendingResetEmail')}: ${state.message}");
        } else if (state is LoginError) {
          showErrorDialog(context,
              "${AppLocalizations.getString(context, 'loginError')}\n${state.error}");
        } else if (state is RegistrationError) {
          showErrorDialog(context,
              "${AppLocalizations.getString(context, 'registrationError')}\n${state.error}");
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
