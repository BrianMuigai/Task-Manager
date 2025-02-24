import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/auth/presentation/bloc/auth_bloc.dart';

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
      appBar: AppBar(title: Text("Register")),
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
                            "Create a new account",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Sign up to manage your tasks, collaborate with your team, and stay organized. Please fill in the details below.",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 32),
                          TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(
                              labelText: "Display Name",
                              border: OutlineInputBorder(),
                            ),
                            enabled: state is! AuthLoading,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please enter your name"
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                            enabled: state is! AuthLoading,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please enter your email"
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            enabled: state is! AuthLoading,
                            validator: (value) => value == null || value.isEmpty
                                ? "Please enter a password"
                                : null,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: state is AuthLoading ? null : _register,
                            child: Text("Register"),
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
                            child: Text("Already have an account? Login"),
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
