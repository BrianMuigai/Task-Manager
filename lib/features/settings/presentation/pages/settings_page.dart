import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/l10n/app_localization.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/settings/presentation/widgets/language_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String displayName = "---";
    String email = "";
    if (authState is Authenticated) {
      displayName = authState.user.displayName;
      email = authState.user.email;
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.getString(context, 'settings')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Info
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(email, textAlign: TextAlign.center),
              SizedBox(height: 8),
              Center(child: LanguageWidget()),
              SizedBox(height: 8),
              SizedBox(height: 24),
              // Logout Button
              if (email.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                  child: Text(AppLocalizations.getString(context, 'logout')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
