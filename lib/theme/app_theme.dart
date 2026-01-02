import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Facebook Colors
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color messengerBlue = Color(0xFF0084FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF0F2F5);
  static const Color mediumGrey = Color(0xFF65676B);
  static const Color darkGrey = Color(0xFF3A3B3C);
  static const Color black = Color(0xFF050505);
  
  // Reaction Colors
  static const Color likeBlue = Color(0xFF1877F2);
  static const Color loveRed = Color(0xFFF33E58);
  static const Color hahaYellow = Color(0xFFF7B125);
  static const Color wowYellow = Color(0xFFF7B125);
  static const Color sadYellow = Color(0xFFF7B125);
  static const Color angryOrange = Color(0xFFE9710F);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: lightGrey,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 1,
      iconTheme: const IconThemeData(color: black),
      titleTextStyle: GoogleFonts.roboto(
        color: facebookBlue,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: facebookBlue,
      unselectedItemColor: mediumGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: lightGrey,
      thickness: 8,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.roboto(
        color: black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.roboto(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.roboto(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.roboto(
        color: black,
        fontSize: 15,
      ),
      bodyMedium: GoogleFonts.roboto(
        color: mediumGrey,
        fontSize: 13,
      ),
      bodySmall: GoogleFonts.roboto(
        color: mediumGrey,
        fontSize: 12,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: facebookBlue,
      secondary: messengerBlue,
      surface: white,
      onPrimary: white,
      onSecondary: white,
      onSurface: black,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF323436), // Keeping dark gray for contrast in light mode too (like FB)
      contentTextStyle: GoogleFonts.roboto(color: white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 6,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: const Color(0xFF18191A),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF242526),
      elevation: 0,
      scrolledUnderElevation: 1,
      iconTheme: const IconThemeData(color: white),
      titleTextStyle: GoogleFonts.roboto(
        color: facebookBlue,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF242526),
      selectedItemColor: facebookBlue,
      unselectedItemColor: Color(0xFFB0B3B8),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF242526),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3A3B3C),
      thickness: 8,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.roboto(
        color: white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.roboto(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(
        color: white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.roboto(
        color: white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.roboto(
        color: white,
        fontSize: 15,
      ),
      bodyMedium: GoogleFonts.roboto(
        color: const Color(0xFFB0B3B8),
        fontSize: 13,
      ),
      bodySmall: GoogleFonts.roboto(
        color: const Color(0xFFB0B3B8),
        fontSize: 12,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: facebookBlue,
      secondary: messengerBlue,
      surface: Color(0xFF242526),
      onPrimary: white,
      onSecondary: white,
      onSurface: white,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF323436),
      contentTextStyle: GoogleFonts.roboto(color: white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 6,
    ),
  );
}
