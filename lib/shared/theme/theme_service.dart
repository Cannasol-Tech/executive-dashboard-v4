import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';
import 'theme_constants.dart';

/// Theme service to manage theme preferences and customization
class ThemeService {
  static const String _themePreferenceKey = 'theme_preference';
  static const String _primaryColorKey = 'primary_color';
  static const String _secondaryColorKey = 'secondary_color';
  static const String _highContrastKey = 'high_contrast';
  static const String _reducedMotionKey = 'reduced_motion';
  static const String _fontSizeAdjustKey = 'font_size_adjust';
  
  /// Available theme modes
  static const Map<String, ThemeMode> themeModes = {
    'system': ThemeMode.system,
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
  };
  
  /// Available theme presets with predefined color combinations
  static final Map<String, ThemePreset> themePresets = {
    'defaultDark': ThemePreset(
      name: 'Default Dark',
      primary: ThemeConstants.deepOcean,
      secondary: ThemeConstants.emeraldGleam,
      isDark: true,
    ),
    'defaultLight': ThemePreset(
      name: 'Default Light',
      primary: ThemeConstants.deepOcean,
      secondary: ThemeConstants.emeraldGleam,
      isDark: false,
    ),
    'oceanSapphire': ThemePreset(
      name: 'Ocean Sapphire',
      primary: ThemeConstants.deepOcean,
      secondary: ThemeConstants.electricSapphire,
      isDark: true,
    ),
    'emeraldDeep': ThemePreset(
      name: 'Emerald Deep',
      primary: ThemeConstants.emeraldGleam,
      secondary: ThemeConstants.deepOcean,
      isDark: true,
    ),
    'royalMagenta': ThemePreset(
      name: 'Royal Magenta',
      primary: ThemeConstants.royalAzure,
      secondary: ThemeConstants.vibrantMagenta,
      isDark: true,
    ),
    'emberNight': ThemePreset(
      name: 'Ember Night',
      primary: ThemeConstants.warmEmber,
      secondary: ThemeConstants.midnight,
      isDark: true,
    ),
  };
  
  /// Initialize theme service
  static Future<void> init() async {
    await _loadPreferences();
  }
  
  /// Current theme mode
  static ThemeMode _themeMode = ThemeMode.system;
  static ThemeMode get themeMode => _themeMode;
  
  /// Current primary color
  static Color _primaryColor = ThemeConstants.deepOcean;
  static Color get primaryColor => _primaryColor;
  
  /// Current secondary color
  static Color _secondaryColor = ThemeConstants.emeraldGleam;
  static Color get secondaryColor => _secondaryColor;
  
  /// High contrast mode
  static bool _highContrast = false;
  static bool get highContrast => _highContrast;
  
  /// Reduced motion mode
  static bool _reducedMotion = false;
  static bool get reducedMotion => _reducedMotion;
  
  /// Font size adjustment factor
  static double _fontSizeAdjust = 1.0;
  static double get fontSizeAdjust => _fontSizeAdjust;
  
  /// Get the active theme based on current settings
  static ThemeData getActiveTheme(BuildContext context) {
    final brightness = _getEffectiveBrightness(context);
    
    return AppThemes.getCustomTheme(
      brightness: brightness,
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      highContrast: _highContrast,
      reducedMotion: _reducedMotion,
    );
  }
  
  /// Set theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    String themeName = 'system';
    
    for (var entry in themeModes.entries) {
      if (entry.value == mode) {
        themeName = entry.key;
        break;
      }
    }
    
    await prefs.setString(_themePreferenceKey, themeName);
  }
  
  /// Set primary color
  static Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
  }
  
  /// Set secondary color
  static Future<void> setSecondaryColor(Color color) async {
    if (_secondaryColor == color) return;
    
    _secondaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_secondaryColorKey, color.value);
  }
  
  /// Set high contrast mode
  static Future<void> setHighContrast(bool value) async {
    if (_highContrast == value) return;
    
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
  }
  
  /// Set reduced motion mode
  static Future<void> setReducedMotion(bool value) async {
    if (_reducedMotion == value) return;
    
    _reducedMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, value);
  }
  
  /// Set font size adjustment
  static Future<void> setFontSizeAdjust(double value) async {
    if (_fontSizeAdjust == value) return;
    
    _fontSizeAdjust = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeAdjustKey, value);
  }
  
  /// Apply a theme preset
  static Future<void> applyThemePreset(String presetKey) async {
    final preset = themePresets[presetKey];
    if (preset == null) return;
    
    // Apply theme settings from the preset
    await setPrimaryColor(preset.primary);
    await setSecondaryColor(preset.secondary);
    
    if (preset.isDark) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  /// Reset theme to defaults
  static Future<void> resetToDefaults() async {
    await setThemeMode(ThemeMode.system);
    await setPrimaryColor(ThemeConstants.deepOcean);
    await setSecondaryColor(ThemeConstants.emeraldGleam);
    await setHighContrast(false);
    await setReducedMotion(false);
    await setFontSizeAdjust(1.0);
  }
  
  /// Load saved preferences
  static Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeName = prefs.getString(_themePreferenceKey) ?? 'system';
    _themeMode = themeModes[themeName] ?? ThemeMode.system;
    
    // Load colors
    final primaryColorValue = prefs.getInt(_primaryColorKey);
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    
    final secondaryColorValue = prefs.getInt(_secondaryColorKey);
    if (secondaryColorValue != null) {
      _secondaryColor = Color(secondaryColorValue);
    }
    
    // Load accessibility settings
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _reducedMotion = prefs.getBool(_reducedMotionKey) ?? false;
    _fontSizeAdjust = prefs.getDouble(_fontSizeAdjustKey) ?? 1.0;
  }
  
  /// Get effective brightness based on theme mode
  static Brightness _getEffectiveBrightness(BuildContext context) {
    if (_themeMode == ThemeMode.light) {
      return Brightness.light;
    } else if (_themeMode == ThemeMode.dark) {
      return Brightness.dark;
    }
    
    // Use system theme as default
    return MediaQuery.platformBrightnessOf(context);
  }
}

/// Theme preset model for predefined themes
class ThemePreset {
  final String name;
  final Color primary;
  final Color secondary;
  final bool isDark;
  
  ThemePreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.isDark,
  });
}