class Validators {
  // Validate that the email is non-empty and in a valid format.
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return "Please enter your email";
    }
    // A basic email regex pattern.
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email.trim())) {
      return "Please enter a valid email";
    }
    return null;
  }

  // Validate that the confirmation email matches the original email.
  static String? validateEmailConfirmation(
      String? email, String? confirmEmail) {
    final emailError = validateEmail(email);
    if (emailError != null) {
      return emailError;
    }
    if (confirmEmail == null || confirmEmail.trim().isEmpty) {
      return "Please confirm your email";
    }
    if (email!.trim() != confirmEmail.trim()) {
      return "Emails do not match";
    }
    return null;
  }

  // Validate that the password is at least 6 characters.
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Please enter your password";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }
}
