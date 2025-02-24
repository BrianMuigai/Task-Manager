import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/validators.dart';
import 'package:task/features/auth/presentation/pages/register_page.dart';
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
        SnackBar(content: Text("Please enter your email first.")),
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
                            "Welcome to Task Manager!",
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
                            "Sign in to manage your tasks, collaborate with others, and stay on top of your schedule.",
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
                                    labelText: "Email",
                                  ),
                                  enabled: state is! AuthLoading,
                                  validator: Validators.validateEmail,
                                ),
                                SizedBox(height: 16),
                                // Password field.
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: "Password",
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
                                  child: Text("Sign In with Email"),
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
                            child: Text("Don't have an account? Register"),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: Text("Forgot Password?"),
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
                                child: Text("OR"),
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
                            label: Text("Continue with Google"),
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
