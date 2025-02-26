import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/l10n/app_localization.dart';
import 'package:task/core/validators.dart';
import 'package:task/features/auth/presentation/pages/register_page.dart';
import 'package:task/features/settings/presentation/pages/settings_page.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  void _signInWithEmail() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      context.read<AuthBloc>().add(
            EmailSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  void _continueWithGoogle() {
    context.read<AuthBloc>().add(SignInRequested());
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      // Prompt user to enter an email first.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.getString(context, 'enterEmailFirst'))),
      );
      return;
    }
    context.read<AuthBloc>().add(ForgotPasswordRequested(email));
  }

  @override
  Widget build(BuildContext context) {
    // Material 3 style configuration (if not already in your theme)
    final ButtonStyle emailButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    final ButtonStyle googleButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: Colors.grey.shade300),
      elevation: 0,
      // surfaceTintColor is used in Material 3 to tint the button's surface.
      surfaceTintColor: Colors.transparent,
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    return Scaffold(
      appBar: AppBar(
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
          if (state is LoginError) {
            setState(() {
              _errorMessage = state.error;
            });
          }
        },
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            return Column(
              children: [
                if (state is AuthLoading)
                  Center(child: LinearProgressIndicator()),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.getString(context, 'welcomeMsg'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Text(
                            AppLocalizations.getString(context, 'signInIntro'),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 32),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email field.
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.getString(
                                        context, 'email'),
                                  ),
                                  enabled: state is! AuthLoading,
                                  validator: Validators.validateEmail,
                                ),
                                SizedBox(height: 16),
                                // Password field.
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.getString(
                                        context, 'password'),
                                  ),
                                  enabled: state is! AuthLoading,
                                  obscureText: true,
                                  validator: Validators.validatePassword,
                                ),
                                SizedBox(height: 16),
                                // Email/Password Sign-In Button with Material 3 styling.
                                ElevatedButton(
                                  style: emailButtonStyle,
                                  onPressed: state is AuthLoading
                                      ? null
                                      : _signInWithEmail,
                                  child: Text(AppLocalizations.getString(
                                      context, 'signInWithEmail')),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text(AppLocalizations.getString(
                                context, 'dontHaveAcc')),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: Text(AppLocalizations.getString(
                                  context, 'forgotPassword')),
                            ),
                          ),

                          SizedBox(height: 16),
                          // Divider.
                          Row(
                            children: <Widget>[
                              Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                    AppLocalizations.getString(context, 'or')
                                        .toUpperCase()),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Google Sign-In Button styled like a Material 3 Google button.
                          ElevatedButton.icon(
                            style: googleButtonStyle,
                            icon: Image.asset(
                              'assets/imgs/google_logo.png',
                              height: 24,
                              width: 24,
                            ),
                            label: Text(AppLocalizations.getString(
                                context, 'continueWithGoogle')),
                            onPressed: state is AuthLoading
                                ? null
                                : _continueWithGoogle,
                          ),
                          if (_errorMessage != null) ...[
                            SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
