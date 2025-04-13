import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme constants based on the design system
class ThemeConstants {
  // Private constructor to prevent instantiation
  ThemeConstants._();
  
  /// Primary Colors
  static const Color deepOcean = Color(0xFF0A192F);
  static const Color emeraldGleam = Color(0xFF26D07C);
  static const Color royalAzure = Color(0xFF0062FF);
  static const Color moonlight = Color(0xFFF8F9FC);
  static const Color nightSky = Color(0xFF070E1A);
  
  /// Accent Colors
  static const Color vibrantMagenta = Color(0xFFC13584);
  static const Color deepOnyx = Color(0xFF010101);
  static const Color warmEmber = Color(0xFFFF4500);
  static const Color electricSapphire = Color(0xFF1DA1F2);
  static const Color vividCrimson = Color(0xFFFF0000);
  
  /// Neutral Colors
  static const Color snowWhite = Color(0xFFFFFFFF);
  static const Color whisper = Color(0xFFF9FAFB);
  static const Color mist = Color(0xFFF3F4F6);
  static const Color silver = Color(0xFFE5E7EB);
  static const Color smoke = Color(0xFFD1D5DB);
  static const Color steel = Color(0xFF9CA3AF);
  static const Color slate = Color(0xFF6B7280);
  static const Color graphite = Color(0xFF4B5563);
  static const Color charcoal = Color(0xFF374151);
  static const Color obsidian = Color(0xFF1F2937);
  static const Color midnight = Color(0xFF111827);
  
  /// Semantic Colors
  static const Color successEmerald = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRuby = Color(0xFFEF4444);
  static const Color infoSapphire = Color(0xFF3B82F6);
  
  /// Gradients
  static const LinearGradient premiumBrandGradient = LinearGradient(
    colors: [deepOcean, emeraldGleam],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const RadialGradient actionGradient = RadialGradient(
    colors: [emeraldGleam, deepOcean],
    center: Alignment.center,
    radius: 1.0,
  );
  
  static const LinearGradient nightOceanGradient = LinearGradient(
    colors: [nightSky, deepOcean],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient subtleCardGradient = LinearGradient(
    colors: [moonlight, snowWhite],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Spacing Scale (in logical pixels)
  static const double spaceNano = 2;
  static const double spaceMicro = 4;
  static const double spaceTiny = 8;
  static const double spaceSmall = 12;
  static const double spaceMedium = 16;
  static const double spaceLarge = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;
  static const double space3XL = 64;
  static const double space4XL = 96;
  
  /// Border Radius
  static const double radiusNone = 0;
  static const double radiusXS = 2;
  static const double radiusSM = 4;
  static const double radiusMD = 8;
  static const double radiusLG = 12;
  static const double radiusXL = 16;
  static const double radiusXXL = 24;
  static const double radiusFull = 9999;
  
  /// Elevation Shadows
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 25,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> elevation5 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 50,
      offset: const Offset(0, 25),
    ),
  ];
  
  /// Animation Durations
  static const Duration durationInstant = Duration(milliseconds: 50);
  static const Duration durationQuick = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);
  
  /// Animation Curves
  static const Curve curveStandard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve curveEntrance = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve curveExit = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve curveBounce = Cubic(0.175, 0.885, 0.32, 1.275);
  static const Curve curveSmooth = Cubic(0.645, 0.045, 0.355, 1.0);
  
  /// Typography
  /// Getting Google Fonts
  static TextTheme getPoppinsTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base);
  }
  
  static TextTheme getInterTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }
  
  static TextTheme getPlayfairDisplayTextTheme(TextTheme base) {
    return GoogleFonts.playfairDisplayTextTheme(base);
  }
  
  static TextTheme getJetBrainsMonoTextTheme(TextTheme base) {
    return GoogleFonts.jetBrainsMonoTextTheme(base);
  }
  
  /// Text Styles
  static TextStyle heroDisplay(Color color) => GoogleFonts.playfairDisplay(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.1,
    color: color,
  );
  
  static TextStyle displayLarge(Color color) => GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
    color: color,
  );
  
  static TextStyle displayMedium(Color color) => GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
    color: color,
  );
  
  static TextStyle displaySmall(Color color) => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.2,
    color: color,
  );
  
  static TextStyle headlineMedium(Color color) => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: color,
  );
  
  static TextStyle titleLarge(Color color) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: color,
  );
  
  static TextStyle titleMedium(Color color) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: color,
  );
  
  static TextStyle titleSmall(Color color) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: color,
  );
  
  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.5,
    color: color,
  );
  
  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
    color: color,
  );
  
  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
    color: color,
  );
  
  static TextStyle label(Color color) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
    color: color,
  );
}