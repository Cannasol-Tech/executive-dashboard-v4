import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/theme/theme_constants.dart';
import '../shared/theme/theme_provider.dart';
import '../shared/theme/theme_service.dart';

/// This file exports all theme-related functionality
/// and provides convenience methods for theme access

/// Initialize the theme system
Future<void> initializeTheme() async {
  await ThemeService.init();
}

/// Get ThemeProvider from context
ThemeProvider getThemeProvider(BuildContext context) {
  return Provider.of<ThemeProvider>(context, listen: false);
}

/// Get current theme data from context
ThemeData getTheme(BuildContext context) {
  return Theme.of(context);
}

/// Create a ChangeNotifierProvider for theme
ChangeNotifierProvider<ThemeProvider> createThemeProvider() {
  return ChangeNotifierProvider<ThemeProvider>(
    create: (_) => ThemeProvider(),
  );
}

/// Wrap your MaterialApp with this function to enable theme customization
Widget withCustomTheme({
  required Widget child, 
  required ThemeProvider themeProvider,
  required BuildContext context,
}) {
  // Get the active theme based on current settings
  final ThemeData activeTheme = themeProvider.getActiveTheme(context);
  
  return Theme(
    data: activeTheme,
    child: child,
  );
}

/// Export theme constants for direct access
const deepOcean = ThemeConstants.deepOcean;
const emeraldGleam = ThemeConstants.emeraldGleam;
const royalAzure = ThemeConstants.royalAzure;
const moonlight = ThemeConstants.moonlight;
const nightSky = ThemeConstants.nightSky;

/// Export spacing constants
const spaceTiny = ThemeConstants.spaceTiny; 
const spaceSmall = ThemeConstants.spaceSmall;
const spaceMedium = ThemeConstants.spaceMedium;
const spaceLarge = ThemeConstants.spaceLarge;
const spaceXL = ThemeConstants.spaceXL;

/// Export radius constants
const radiusSM = ThemeConstants.radiusSM;
const radiusMD = ThemeConstants.radiusMD;
const radiusLG = ThemeConstants.radiusLG;
const radiusFull = ThemeConstants.radiusFull;