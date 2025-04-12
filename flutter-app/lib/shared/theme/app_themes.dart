import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_constants.dart';

/// Defines the application themes based on the design system
class AppThemes {
  // Private constructor to prevent instantiation
  AppThemes._();
  
  /// Get a custom theme with user-defined primary and secondary colors
  static ThemeData getCustomTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor,
    bool highContrast = false,
    bool reducedMotion = false,
  }) {
    final bool isDark = brightness == Brightness.dark;
    
    // Use base color scheme as foundation, then customize
    final colorScheme = isDark ? darkColorScheme : lightColorScheme;
    
    // Create a custom color scheme with the user's chosen colors
    final customColorScheme = colorScheme.copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      // Adjust primary container and secondary container colors based on the chosen colors
      primaryContainer: primaryColor.withOpacity(0.2),
      secondaryContainer: secondaryColor.withOpacity(0.2),
    );
    
    // Creating shared theme data
    return _createThemeData(
      colorScheme: customColorScheme, 
      isDark: isDark,
      highContrast: highContrast,
      reducedMotion: reducedMotion,
    );
  }
  
  /// Light theme - default theme
  static ThemeData get lightTheme => _createThemeData(
    colorScheme: lightColorScheme,
    isDark: false,
    highContrast: false,
    reducedMotion: false,
  );
  
  /// Dark theme
  static ThemeData get darkTheme => _createThemeData(
    colorScheme: darkColorScheme,
    isDark: true,
    highContrast: false,
    reducedMotion: false,
  );
  
  /// High contrast light theme for accessibility
  static ThemeData get highContrastLightTheme => _createThemeData(
    colorScheme: lightColorScheme,
    isDark: false,
    highContrast: true,
    reducedMotion: false,
  );
  
  /// High contrast dark theme for accessibility
  static ThemeData get highContrastDarkTheme => _createThemeData(
    colorScheme: darkColorScheme, 
    isDark: true,
    highContrast: true,
    reducedMotion: false,
  );
  
  /// Reduced motion light theme
  static ThemeData get reducedMotionLightTheme => _createThemeData(
    colorScheme: lightColorScheme,
    isDark: false,
    highContrast: false,
    reducedMotion: true,
  );
  
  /// Reduced motion dark theme
  static ThemeData get reducedMotionDarkTheme => _createThemeData(
    colorScheme: darkColorScheme,
    isDark: true,
    highContrast: false,
    reducedMotion: true,
  );
  
  /// Base light color scheme derived from the design system
  static ColorScheme get lightColorScheme {
    return const ColorScheme(
      // Primary
      primary: ThemeConstants.deepOcean,
      onPrimary: ThemeConstants.snowWhite,
      primaryContainer: Color(0xFFDDE5FF),
      onPrimaryContainer: Color(0xFF001944),
      
      // Secondary
      secondary: ThemeConstants.emeraldGleam,
      onSecondary: ThemeConstants.snowWhite,
      secondaryContainer: Color(0xFFD1FFD7),
      onSecondaryContainer: Color(0xFF002108),
      
      // Surface & Background
      surface: ThemeConstants.snowWhite,
      onSurface: ThemeConstants.obsidian,
      surfaceVariant: ThemeConstants.whisper,
      onSurfaceVariant: ThemeConstants.graphite,
      
      // Background
      background: ThemeConstants.moonlight,
      onBackground: ThemeConstants.obsidian,
      
      // Error
      error: ThemeConstants.errorRuby,
      onError: ThemeConstants.snowWhite,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      
      // Extended colors
      outline: ThemeConstants.silver,
      outlineVariant: ThemeConstants.mist,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ThemeConstants.obsidian,
      onInverseSurface: ThemeConstants.moonlight,
      inversePrimary: ThemeConstants.royalAzure,
      surfaceTint: ThemeConstants.deepOcean,
      
      // Brightness
      brightness: Brightness.light,
    );
  }
  
  /// Base dark color scheme derived from the design system
  static ColorScheme get darkColorScheme {
    return const ColorScheme(
      // Primary
      primary: ThemeConstants.emeraldGleam,
      onPrimary: ThemeConstants.deepOcean,
      primaryContainer: Color(0xFF004881),
      onPrimaryContainer: ThemeConstants.moonlight,
      
      // Secondary
      secondary: ThemeConstants.royalAzure,
      onSecondary: ThemeConstants.snowWhite,
      secondaryContainer: Color(0xFF00432A),
      onSecondaryContainer: ThemeConstants.moonlight,
      
      // Surface & Background
      surface: ThemeConstants.deepOcean,
      onSurface: ThemeConstants.moonlight,
      surfaceVariant: Color(0xFF101E35),
      onSurfaceVariant: ThemeConstants.silver,
      
      // Background
      background: ThemeConstants.nightSky,
      onBackground: ThemeConstants.moonlight,
      
      // Error
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690002),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      
      // Extended colors
      outline: ThemeConstants.slate,
      outlineVariant: ThemeConstants.charcoal,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ThemeConstants.whisper,
      onInverseSurface: ThemeConstants.obsidian,
      inversePrimary: ThemeConstants.deepOcean,
      surfaceTint: ThemeConstants.emeraldGleam,
      
      // Brightness
      brightness: Brightness.dark,
    );
  }
  
  /// Create a complete ThemeData object that applies all design system parameters
  static ThemeData _createThemeData({
    required ColorScheme colorScheme,
    required bool isDark,
    required bool highContrast,
    required bool reducedMotion,
  }) {
    // Text colors - adjust based on high contrast mode
    final textColor = isDark 
      ? (highContrast ? ThemeConstants.snowWhite : ThemeConstants.moonlight)
      : (highContrast ? ThemeConstants.midnight : ThemeConstants.obsidian);
      
    final subtleTextColor = isDark
      ? (highContrast ? ThemeConstants.mist : ThemeConstants.steel)
      : (highContrast ? ThemeConstants.charcoal : ThemeConstants.slate);
    
    // Create base text theme using the design system typography
    final baseTextTheme = ThemeConstants.getInterTextTheme(
      TextTheme(
        // Display styles
        displayLarge: ThemeConstants.displayLarge(textColor),
        displayMedium: ThemeConstants.displayMedium(textColor),
        displaySmall: ThemeConstants.displaySmall(textColor),
        
        // Headline styles
        headlineLarge: ThemeConstants.headlineMedium(textColor).copyWith(
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        headlineMedium: ThemeConstants.headlineMedium(textColor),
        headlineSmall: ThemeConstants.headlineMedium(textColor).copyWith(
          fontSize: 24,
          letterSpacing: 0,
        ),
        
        // Title styles
        titleLarge: ThemeConstants.titleLarge(textColor),
        titleMedium: ThemeConstants.titleMedium(textColor),
        titleSmall: ThemeConstants.titleSmall(textColor),
        
        // Body styles
        bodyLarge: ThemeConstants.bodyLarge(textColor),
        bodyMedium: ThemeConstants.bodyMedium(textColor),
        bodySmall: ThemeConstants.bodySmall(subtleTextColor),
        
        // Label styles
        labelLarge: ThemeConstants.label(textColor).copyWith(
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelMedium: ThemeConstants.label(textColor),
        labelSmall: ThemeConstants.label(subtleTextColor).copyWith(
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
    
    // Custom page transitions for animations - respect reduced motion setting
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: reducedMotion 
          ? const FadeUpwardsPageTransitionsBuilder() 
          : const CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: reducedMotion 
          ? const FadeUpwardsPageTransitionsBuilder() 
          : const CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: const ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: const FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
      },
    );
    
    return ThemeData(
      // Color scheme
      colorScheme: colorScheme,
      
      // Set brightness
      brightness: colorScheme.brightness,
      
      // Use Material 3
      useMaterial3: true,
      
      // Typography
      textTheme: baseTextTheme,
      primaryTextTheme: baseTextTheme,
      
      // Colors
      primaryColor: colorScheme.primary,
      primaryColorDark: isDark ? ThemeConstants.nightSky : ThemeConstants.obsidian,
      primaryColorLight: isDark ? ThemeConstants.emeraldGleam.withOpacity(0.7) : ThemeConstants.royalAzure.withOpacity(0.7),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.outline,
      disabledColor: isDark ? ThemeConstants.charcoal : ThemeConstants.smoke,
      
      // App bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: ThemeConstants.nightSky,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: ThemeConstants.moonlight,
              ),
      ),
      
      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.7),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceLarge,
            vertical: ThemeConstants.spaceSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          ),
          textStyle: ThemeConstants.label(Colors.white).copyWith(fontSize: 14),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceLarge,
            vertical: ThemeConstants.spaceSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          textStyle: ThemeConstants.label(colorScheme.primary).copyWith(fontSize: 14),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spaceSmall,
            vertical: ThemeConstants.spaceTiny,
          ),
          textStyle: ThemeConstants.label(colorScheme.primary).copyWith(fontSize: 14),
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLG),
        ),
        color: colorScheme.surface,
        margin: const EdgeInsets.all(ThemeConstants.spaceTiny),
      ),
      
      // Dialogs
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? ThemeConstants.obsidian : ThemeConstants.deepOcean,
        contentTextStyle: ThemeConstants.bodyMedium(ThemeConstants.moonlight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.all(ThemeConstants.spaceSmall),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMD),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2.0,
          ),
        ),
        labelStyle: ThemeConstants.bodyMedium(colorScheme.onSurfaceVariant),
        hintStyle: ThemeConstants.bodyMedium(colorScheme.onSurfaceVariant.withOpacity(0.6)),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.1);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.secondary;
          }
          return colorScheme.outline;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXS),
        ),
      ),
      
      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.1);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.secondary;
          }
          return colorScheme.outline;
        }),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.1);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.secondary;
          }
          return colorScheme.outline;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurface.withOpacity(0.05);
          }
          if (states.contains(MaterialState.selected)) {
            return colorScheme.secondary.withOpacity(0.5);
          }
          return colorScheme.outline.withOpacity(0.3);
        }),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.secondary,
        inactiveTrackColor: colorScheme.surfaceVariant,
        thumbColor: colorScheme.secondary,
        overlayColor: colorScheme.secondary.withOpacity(0.2),
      ),
      
      // Tab Bar
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
        labelStyle: ThemeConstants.label(colorScheme.primary).copyWith(fontSize: 14),
        unselectedLabelStyle: ThemeConstants.label(colorScheme.onSurface.withOpacity(0.7)).copyWith(fontSize: 14),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2.0,
            color: colorScheme.primary,
          ),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        disabledColor: colorScheme.surfaceVariant.withOpacity(0.5),
        selectedColor: colorScheme.secondaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        labelStyle: ThemeConstants.label(colorScheme.onSurfaceVariant),
        secondaryLabelStyle: ThemeConstants.label(colorScheme.onSurfaceVariant),
        brightness: colorScheme.brightness,
        padding: const EdgeInsets.all(ThemeConstants.spaceSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
        ),
      ),
      
      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? ThemeConstants.charcoal : ThemeConstants.obsidian.withOpacity(0.9),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSM),
        ),
        textStyle: ThemeConstants.bodySmall(ThemeConstants.moonlight),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
        circularTrackColor: colorScheme.surfaceVariant,
        linearTrackColor: colorScheme.surfaceVariant,
      ),
      
      // Animations 
      pageTransitionsTheme: pageTransitionsTheme,
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: ThemeConstants.spaceTiny,
      ),
    );
  }
}