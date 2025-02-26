import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/l10n/app_localization.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task/features/settings/presentation/pages/settings_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(RegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _displayNameController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getString(context, 'register')),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegistrationError) {
            setState(() {
              _errorMessage = state.error;
            });
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          return Column(
            children: [
              if (state is AuthLoading)
                Center(child: CircularProgressIndicator.adaptive()),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.getString(context, 'createNewAcc'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.getString(context, 'signUpIntro'),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 32),
                          TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.getString(
                                  context, 'displayName'),
                              border: OutlineInputBorder(),
                            ),
                            enabled: state is! AuthLoading,
                            validator: (value) => value == null || value.isEmpty
                                ? AppLocalizations.getString(
                                    context, 'enterName')
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.getString(context, 'email'),
                              border: OutlineInputBorder(),
                            ),
                            enabled: state is! AuthLoading,
                            validator: (value) => value == null || value.isEmpty
                                ? AppLocalizations.getString(
                                    context, 'enterEmail')
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.getString(
                                  context, 'password'),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            enabled: state is! AuthLoading,
                            validator: (value) => value == null || value.isEmpty
                                ? AppLocalizations.getString(
                                    context, 'enterPassword')
                                : null,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: state is AuthLoading ? null : _register,
                            child: Text(AppLocalizations.getString(
                                context, 'register')),
                          ),
                          if (_errorMessage != null) ...[
                            SizedBox(height: 16),
                            Text(_errorMessage!,
                                style: TextStyle(color: Colors.red)),
                          ],
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.getString(
                                context, 'alreadyHaveAcc')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
