import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Slideshow pace
// ---------------------------------------------------------------------------

enum SlideshowPace { fast, normal, slow }

// ---------------------------------------------------------------------------
// Color theme presets
// ---------------------------------------------------------------------------

class AppColorTheme {
  final String name;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final Color accent;
  final Color primary;

  const AppColorTheme({
    required this.name,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.accent,
    required this.primary,
  });

  static const List<AppColorTheme> presets = [sanctuary, sunrise, ocean];

  static const sanctuary = AppColorTheme(
    name: 'Sanctuary',
    gradientStart: Color(0xFFe0c3fc),
    gradientMid: Color(0xFF8ec5fc),
    gradientEnd: Color(0xFF6C4DFF),
    accent: Color(0xFF00D2FF),
    primary: Color(0xFF6C4DFF),
  );

  static const sunrise = AppColorTheme(
    name: 'Sunrise',
    gradientStart: Color(0xFFFFE1CC),
    gradientMid: Color(0xFFFFB347),
    gradientEnd: Color(0xFFE8685A),
    accent: Color(0xFFF9A825),
    primary: Color(0xFFD4553F),
  );

  static const ocean = AppColorTheme(
    name: 'Ocean',
    gradientStart: Color(0xFFB2EBF2),
    gradientMid: Color(0xFF00ACC1),
    gradientEnd: Color(0xFF01579B),
    accent: Color(0xFF26C6DA),
    primary: Color(0xFF01579B),
  );
}

// ---------------------------------------------------------------------------
// App theme
// ---------------------------------------------------------------------------

class AppTheme {
  static const Color primary = Color(0xFF6C4DFF);
  static const Color accent = Color(0xFF00D2FF);
  static const Color background = Color(0xFFF8F9FB);
  static const Color cardGradientStart = Color(0xFFe0c3fc);
  static const Color cardGradientEnd = Color(0xFF8ec5fc);
  static const Color cardShadow = Color(0x1A000000);
  static const Color textPrimary = Color(0xFF22223B);
  static const Color textSecondary = Color(0xFF4A4E69);
  static const Color favorite = Color(0xFFFF6B81);

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 38,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.w500,
          fontSize: 19,
          color: textSecondary,
          letterSpacing: 0.1,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontWeight: FontWeight.w400,
          fontSize: 16.5,
          color: textSecondary,
          letterSpacing: 0.05,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: primary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 14,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        color: Colors.white,
        shadowColor: cardShadow,
      ),
      iconTheme: const IconThemeData(color: primary),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        showUnselectedLabels: true,
        elevation: 12,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, letterSpacing: 0.05),
      ),
      useMaterial3: true,
    );
  }
}

class AppMotion {
  static const Duration quick = Duration(milliseconds: 220);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration cardEntrance = Duration(milliseconds: 600);
  static const Duration controlPress = Duration(milliseconds: 250);
  static const Duration slideshowPage = Duration(milliseconds: 500);
  static const Duration ambientCycle = Duration(seconds: 8);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve emphasizedIn = Curves.easeInCubic;
  static const Curve entrance = Curves.easeOutBack;
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve playful = Curves.elasticOut;
}
