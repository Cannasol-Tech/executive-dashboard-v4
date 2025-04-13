import 'package:flutter/material.dart';
import 'theme_service.dart';

/// Provider for theme management
class ThemeProvider with ChangeNotifier {
  /// The current theme mode
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  
  /// Current primary color
  Color _primaryColor = ThemeService.primaryColor;
  Color get primaryColor => _primaryColor;
  
  /// Current secondary color
  Color _secondaryColor = ThemeService.secondaryColor;
  Color get secondaryColor => _secondaryColor;
  
  /// High contrast mode
  bool _highContrast = ThemeService.highContrast;
  bool get highContrast => _highContrast;
  
  /// Reduced motion mode
  bool _reducedMotion = ThemeService.reducedMotion;
  bool get reducedMotion => _reducedMotion;
  
  /// Font size adjustment
  double _fontSizeAdjust = ThemeService.fontSizeAdjust;
  double get fontSizeAdjust => _fontSizeAdjust;
  
  /// Initialize the theme provider
  ThemeProvider() {
    _initFromService();
  }
  
  /// Initialize state from the ThemeService
  Future<void> _initFromService() async {
    _themeMode = ThemeService.themeMode;
    _primaryColor = ThemeService.primaryColor;
    _secondaryColor = ThemeService.secondaryColor;
    _highContrast = ThemeService.highContrast;
    _reducedMotion = ThemeService.reducedMotion;
    _fontSizeAdjust = ThemeService.fontSizeAdjust;
    notifyListeners();
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    await ThemeService.setThemeMode(mode);
    notifyListeners();
  }
  
  /// Set primary color
  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor == color) return;
    
    _primaryColor = color;
    await ThemeService.setPrimaryColor(color);
    notifyListeners();
  }
  
  /// Set secondary color
  Future<void> setSecondaryColor(Color color) async {
    if (_secondaryColor == color) return;
    
    _secondaryColor = color;
    await ThemeService.setSecondaryColor(color);
    notifyListeners();
  }
  
  /// Set high contrast mode
  Future<void> setHighContrast(bool value) async {
    if (_highContrast == value) return;
    
    _highContrast = value;
    await ThemeService.setHighContrast(value);
    notifyListeners();
  }
  
  /// Set reduced motion mode
  Future<void> setReducedMotion(bool value) async {
    if (_reducedMotion == value) return;
    
    _reducedMotion = value;
    await ThemeService.setReducedMotion(value);
    notifyListeners();
  }
  
  /// Set font size adjustment
  Future<void> setFontSizeAdjust(double value) async {
    if (_fontSizeAdjust == value) return;
    
    _fontSizeAdjust = value;
    await ThemeService.setFontSizeAdjust(value);
    notifyListeners();
  }
  
  /// Apply a theme preset
  Future<void> applyThemePreset(String presetKey) async {
    await ThemeService.applyThemePreset(presetKey);
    await _initFromService(); // Reload all settings
  }
  
  /// Reset theme to defaults
  Future<void> resetToDefaults() async {
    await ThemeService.resetToDefaults();
    await _initFromService(); // Reload all settings
  }
  
  /// Get the active theme
  ThemeData getActiveTheme(BuildContext context) {
    return ThemeService.getActiveTheme(context);
  }
}