import 'package:flutter/material.dart';

/// A sample brand color that matches the green accent from the reference image.
/// Adjust as needed.
const Color kBrandGreen = Color(0xFF23AA49);

/// A near-white background color for light theme.
const Color kLightBackground = Color(0xFFF5F5F5);

/// A near-black background color for dark theme.
const Color kDarkBackground = Color(0xFF121212);

ThemeData buildLightTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kLightBackground,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: kBrandGreen,
      onPrimary: Colors.white,
      secondary: Colors.black54,
    ),
    // Text Theme: adjusts global text styles
    textTheme: base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: Colors.black87,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    // Input (TextFormField) decoration theme
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: Colors.grey.shade300), // Gray border color
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kBrandGreen),
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(color: Colors.black87),
      hintStyle: TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDarkBackground,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: kBrandGreen,
      onPrimary: Colors.white,
      secondary: Colors.white70,
    ),
    textTheme: base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: Colors.white70,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF1E1E1E),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kBrandGreen),
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kBrandGreen,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
  );
}
