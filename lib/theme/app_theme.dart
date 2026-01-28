import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium, modern theme configuration for the Yapper application.
/// Focuses on a "Midnight Studio" aesthetic with high-contrast accents
/// and soft, spacious UI elements.
class AppTheme {
  // --- Brand Colors (Midnight Studio Palette) ---
  static const Color primaryColor = Color(0xFF6366F1); // Electric Indigo
  static const Color secondaryColor = Color(0xFFA855F7); // Royal Purple
  static const Color accentColor = Color(0xFF22D3EE); // Cyan Spark
  
  static const Color bgDark = Color(0xFF0D0D0E); // Deep Obsidian
  static const Color surfaceDark = Color(0xFF161618); // Elevated Slate
  static const Color cardDark = Color(0xFF1E1E21); // Card Surface
  
  static const Color textHigh = Color(0xFFF8FAFC); // Primary Text
  static const Color textMed = Color(0xFF94A3B8); // Secondary/Hint Text
  static const Color textLow = Color(0xFF475569); // Disabled/Muted
  
  static const Color errorColor = Color(0xFFF43F5E); // Rose Error
  static const Color successColor = Color(0xFF10B981); // Emerald Success
  static const Color borderColor = Color(0xFF2D2D30); // Subtle Border

  /// Dark Theme Definition
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primaryColor,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textHigh,
      error: errorColor,
    ),

    // --- Typography (Clean & Spaced) ---
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textHigh,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textHigh,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textHigh,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: textHigh,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        color: textMed,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: textLow,
        letterSpacing: 1.2,
      ),
    ),

    // --- Component Styling ---
    appBarTheme: AppBarTheme(
      backgroundColor: bgDark.withOpacity(0.8),
      foregroundColor: textHigh,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textHigh,
      ),
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      hintStyle: GoogleFonts.outfit(color: textLow, fontSize: 15),
      prefixIconColor: textMed,
      suffixIconColor: textMed,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: errorColor),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}