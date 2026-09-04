import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoBrutalistColors {
  // Light Mode Tokens
  static const Color lightCanvas = Color(0xFFF9F4EB);
  static const Color lightPrimary = Color(0xFFF7CE46); // Canary Yellow
  static const Color lightAccent = Color(0xFFEE5A24);  // Terracotta Orange
  static const Color lightBorder = Color(0xFF111111);  // High contrast Black
  static const Color lightText = Color(0xFF111111);
  static const Color lightMutedText = Color(0xFF555555);
  static const Color lightCardBg = Color(0xFFFFFFFF);

  // Refined Dark Mode Tokens ("Obsidian & Cyber Canary")
  static const Color darkCanvas = Color(0xFF0C0C0E);   // Deep Obsidian Black
  static const Color darkPrimary = Color(0xFFF7CE46);  // Electric Canary Yellow (Brand Identity preserved!)
  static const Color darkAccent = Color(0xFFFF5722);   // Vibrant Cyber Tangerine
  static const Color darkBorder = Color(0xFF2E2E36);   // Architectural Steel Outline (no blinding white glare)
  static const Color darkText = Color(0xFFF4F4F6);     // Crisp Clean White
  static const Color darkMutedText = Color(0xFF8E8E98); // Sleek Zinc Gray
  static const Color darkCardBg = Color(0xFF18181C);   // Elevated Deep Charcoal
  static const Color darkHeaderBg = Color(0xFF121215); // Deep Charcoal Header

  // Utility colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
}

class NeoBrutalistTheme {
  static const double borderWidth = 1.2;
  static const double borderRadius = 4.0;
  static const Offset shadowOffset = Offset(3.0, 3.0);

  static ThemeData lightTheme() {
    final baseTextTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NeoBrutalistColors.lightCanvas,
      primaryColor: NeoBrutalistColors.lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: NeoBrutalistColors.lightPrimary,
        secondary: NeoBrutalistColors.lightAccent,
        surface: NeoBrutalistColors.lightCardBg,
        onSurface: NeoBrutalistColors.lightText,
        onPrimary: NeoBrutalistColors.lightText,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: NeoBrutalistColors.lightText,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: NeoBrutalistColors.lightText,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: NeoBrutalistColors.lightText,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: NeoBrutalistColors.lightText,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoBrutalistColors.lightPrimary,
        foregroundColor: NeoBrutalistColors.lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: NeoBrutalistColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        shape: const Border(
          bottom: BorderSide(
            color: NeoBrutalistColors.lightBorder,
            width: borderWidth,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NeoBrutalistColors.lightBorder,
        thickness: borderWidth,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: NeoBrutalistColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(
            color: NeoBrutalistColors.lightBorder,
            width: borderWidth,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final baseTextTheme = GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NeoBrutalistColors.darkCanvas,
      primaryColor: NeoBrutalistColors.darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: NeoBrutalistColors.darkPrimary,
        secondary: NeoBrutalistColors.darkAccent,
        surface: NeoBrutalistColors.darkCardBg,
        onSurface: NeoBrutalistColors.darkText,
        onPrimary: Colors.black, // Black on yellow primary elements for optimal contrast
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: NeoBrutalistColors.darkText,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: NeoBrutalistColors.darkText,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: NeoBrutalistColors.darkText,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: NeoBrutalistColors.darkText,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoBrutalistColors.darkHeaderBg,
        foregroundColor: NeoBrutalistColors.darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: NeoBrutalistColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        shape: const Border(
          bottom: BorderSide(
            color: NeoBrutalistColors.darkBorder,
            width: borderWidth,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NeoBrutalistColors.darkBorder,
        thickness: borderWidth,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: NeoBrutalistColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(
            color: NeoBrutalistColors.darkBorder,
            width: borderWidth,
          ),
        ),
      ),
    );
  }
}
