import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme configuration for Cannasol Executive Dashboard
/// Based on the design system defined in axovia-ai/architecture/design-system.md
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Primary Colors
  static const Color deepOcean = Color(0xFF0A192F);
  static const Color emeraldGleam = Color(0xFF26D07C);
  static const Color royalAzure = Color(0xFF0062FF);
  static const Color moonlight = Color(0xFFF8F9FC);
  static const Color nightSky = Color(0xFF070E1A);

  // Neutral Colors
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

  // Semantic Colors
  static const Color successEmerald = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoSapphire = Color(0xFF3B82F6);
  static const Color errorRuby = Color(0xFFEF4444); // Add

  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFF374151);
  static const Color borderDisabled = Color(0xFF9CA3AF);
  static const Color borderHover = Color(0xFF4B5563);
  static const Color borderActive = Color(0xFF111827);
  static const Color borderFocus = Color(0xFF3B82F6);
  static const Color borderError = Color(0xFFEF4444);
  static const Color borderSuccess = Color(0xFF10B981);
  static const Color borderWarning = Color(0xFFF59E0B);
  static const Color borderInfo = Color(0xFF3B82F6);
  static const Color borderDisabledLight = Color(0xFF9CA3AF);
  static const Color borderDisabledDark = Color(0xFF374151);
  static const Color borderActiveLight = Color(0xFF4B5563);
  static const Color borderActiveDark = Color(0xFF111827);
  static const Color borderFocusLight = Color(0xFF3B82F6);
  static const Color borderFocusDark = Color(0xFF3B82F6);
  static const Color borderErrorLight = Color(0xFFEF4444);
  static const Color borderErrorDark = Color(0xFFEF4444);
  static const Color borderSuccessLight = Color(0xFF10B981);
  static const Color borderSuccessDark = Color(0xFF10B981);
  static const Color borderWarningLight = Color(0xFFF59E0B);
  static const Color borderWarningDark = Color(0xFFF59E0B);
  static const Color borderInfoLight = Color(0xFF3B82F6);
  static const Color borderInfoDark = Color(0xFF3B82F6);
  static const Color borderSubtleLight = Color(0xFFE5E7EB);
  static const Color borderSubtleDark = Color(0xFF374151);
  static const Color borderStrongLight = Color(0xFF374151);
  static const Color borderStrongDark = Color(0xFF111827);

  // Gradient Definitions
  static const LinearGradient premiumBrand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepOcean, emeraldGleam],
  );

  static const RadialGradient actionGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [emeraldGleam, deepOcean],
  );

  static const LinearGradient nightOcean = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [nightSky, deepOcean],
  );

  static const LinearGradient subtleCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [moonlight, snowWhite],
  );

  static getSubtleCard(double opacity) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        moonlight.withOpacity(opacity),
        snowWhite.withOpacity(opacity),
      ],
    );
  }

  static getLinearGradient(double opacity) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        moonlight.withOpacity(opacity),
        snowWhite.withOpacity(opacity),
      ],
    );
  }

  static getRadialGradient(double opacity) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        emeraldGleam.withOpacity(opacity),
        deepOcean.withOpacity(opacity),
      ],
    );
  }

  static getNightOcean(double opacity) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        nightSky.withOpacity(opacity),
        deepOcean.withOpacity(opacity),
      ],
    );
  }

  // Elevation Shadows
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

  get surfaceSecondaryColor => null;

  // Text Styles
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: cardColor,
        onSurface: textPrimaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: Colors.grey[800]!,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.grey[800],
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      dividerTheme: DividerThemeData(
        color: Colors.grey[700]!,
        thickness: 1,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
}
