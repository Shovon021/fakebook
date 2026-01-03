import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Facebook Colors - Polished
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color messengerBlue = Color(0xFF0084FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF0F2F5);
  static const Color mediumGrey = Color(0xFF65676B);
  static const Color darkGrey = Color(0xFF242526);
  static const Color black = Color(0xFF050505);
  static const Color scaffoldLight = Color(0xFFF2F4F7); // Sligthly cooler grey
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Reaction Colors
  static const Color likeBlue = Color(0xFF1877F2);
  static const Color loveRed = Color(0xFFF33E58);
  static const Color hahaYellow = Color(0xFFF7B125);
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: scaffoldLight,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: black),
      titleTextStyle: GoogleFonts.roboto(
        color: facebookBlue,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: facebookBlue,
      unselectedItemColor: mediumGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // We'll handle shadow manually for better look
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 0, // Using manual shadows for better control
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Smoother corners
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFCED0D4), // FB divider color
      thickness: 0.5,
      space: 1,
    ),
    // ... Text theme similar to before but refined
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.roboto(
        color: black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      // ... others
      bodyLarge: GoogleFonts.roboto(
         color: black,
         fontSize: 16,
         height: 1.3,
      ),
      bodyMedium: GoogleFonts.roboto(
         color: const Color(0xFF1C1E21), // FB body text
         fontSize: 15,
         height: 1.4,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: facebookBlue,
      secondary: messengerBlue,
      surface: white,
      onPrimary: white,
      onSecondary: white,
      onSurface: black,
      outline: Color(0xFFCED0D4),
    ),
  );

  // Dark Theme - Deeper blacks and grays
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: const Color(0xFF18191A),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF242526),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFFE4E6EB)),
      titleTextStyle: GoogleFonts.roboto(
        color: facebookBlue,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    // ... similar dark theme updates
    cardTheme: CardThemeData(
      color: const Color(0xFF242526),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3E4042),
      thickness: 0.5,
    ),
    colorScheme: const ColorScheme.dark(
      primary: facebookBlue,
      secondary: messengerBlue,
      surface: Color(0xFF242526),
      onPrimary: white,
      onSecondary: white,
      onSurface: Color(0xFFE4E6EB),
      outline: Color(0xFF3E4042),
    ),
    // ...
  );
}
