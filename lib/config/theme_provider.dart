import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart'; // Updated import

class ThemeProvider extends ChangeNotifier {
  // Key for storing theme preference
  static const String _themePreferenceKey = 'theme_preference';

  // Theme mode - defaults to system
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _currentTheme = AppTheme.lightTheme();

  ThemeProvider() {
    _loadThemePreference();
    if (_themeMode == ThemeMode.dark) {
      _currentTheme = AppTheme.darkTheme();
    } else if (_themeMode == ThemeMode.light) {
      _currentTheme = AppTheme.lightTheme();
    } else {
      _currentTheme = AppTheme.lightTheme();
    }
  }

  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme => _currentTheme;

  // Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Set theme mode and save preference
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, mode.toString());
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);

    if (savedTheme == 'ThemeMode.dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'ThemeMode.light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}
