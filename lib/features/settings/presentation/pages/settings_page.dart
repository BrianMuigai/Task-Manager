import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String displayName = "Unknown User";
    String email = "unknown@example.com";
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
          title: Text("Settings"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              ),
              SizedBox(height: 8),
              Text(email),
              SizedBox(height: 24),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
