# Theme Implementation - Cannasol Executive Dashboard

## Overview

This document outlines the implementation of the theme system for the Cannasol Executive Dashboard, following modern Flutter best practices with a focus on customization, accessibility, and visual appeal.

## Features

- **Dark/Light/System Mode Support**: Automatically adapts to system settings or allows manual selection
- **Custom Color Themes**: User-selectable primary and secondary colors
- **Preset Themes**: Professionally designed theme combinations for quick styling
- **Accessibility Features**:
  - High contrast mode for improved readability
  - Reduced motion mode for users sensitive to animations
  - Text size adjustments for better visibility
- **Persistent Preferences**: Theme settings are saved across app restarts

## File Structure

```
lib/
├── config/
│   └── theme.dart             # Central theme exports and helper methods
├── shared/
│   └── theme/
│       ├── theme_constants.dart  # Design tokens (colors, spacing, typography)
│       ├── app_themes.dart       # ThemeData implementation
│       ├── theme_service.dart    # Theme settings management
│       └── theme_provider.dart   # Provider for theme state
└── features/
    └── settings/
        ├── screens/
        │   └── theme_customization_screen.dart  # Theme customization UI
        └── widgets/
            └── color_palette_preview.dart       # Theme preview component
```

## Implementation Details

### Theme Constants

The `theme_constants.dart` file defines all design tokens based on the design system, including:

- **Colors**: Primary, accent, neutral, and semantic colors
- **Typography**: Text styles for different purposes
- **Spacing**: Standard spacing values for consistent layout
- **Elevation**: Shadow definitions for depth perception
- **Animation**: Duration and curve definitions
- **Border Radius**: Standard border radius values

### Theme Data

The `app_themes.dart` file implements `ThemeData` objects with full theming for all Material components:

- Base light and dark color schemes
- Component-specific theming (cards, buttons, inputs, etc.)
- Adaptive color variations (primary/secondary containers)
- Typography scaling and adjustments
- Animation configurations

### Theme Service

The `theme_service.dart` file manages theme settings:

- Saving/loading preferences using `SharedPreferences`
- Theme mode selection (light/dark/system)
- Custom color selection
- Accessibility settings
- Theme preset management

### Theme Provider

The `theme_provider.dart` file implements a `ChangeNotifier`-based provider for reactive UI updates:

- Exposes theme settings as observable state
- Provides methods to update theme settings
- Handles persistence via the ThemeService

### Theme Customization UI

The `theme_customization_screen.dart` provides a user interface for theme customization:

- Theme mode selection (light/dark/system)
- Theme preset selection with visual preview
- Custom color picker with live preview
- Accessibility settings controls

## Usage

### Basic Usage

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the theme system
  await initializeTheme();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        createThemeProvider(),
      ],
      child: const AppWithTheme(),
    );
  }
}

class AppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      themeMode: themeProvider.themeMode,
      theme: themeProvider.getActiveTheme(context),
      darkTheme: themeProvider.getActiveTheme(context),
      home: const HomeScreen(),
    );
  }
}
```

### Accessing Theme Values

```dart
// Using theme directly
final Color primaryColor = Theme.of(context).colorScheme.primary;
final TextStyle headline = Theme.of(context).textTheme.headline5;

// Using exported constants
import 'package:executive_dashboard/config/theme.dart';

const padding = spaceMedium;
const radius = radiusMD;
const color = deepOcean;
```

### Changing Theme Settings

```dart
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// Change theme mode
themeProvider.setThemeMode(ThemeMode.dark);

// Change primary color
themeProvider.setPrimaryColor(Colors.purple);

// Apply preset theme
themeProvider.applyThemePreset('oceanSapphire');

// Toggle high contrast
themeProvider.setHighContrast(true);
```

## Extending the Theme

### Adding New Color Tokens

1. Add the color to `ThemeConstants` class
2. Include the color in appropriate color schemes in `AppThemes`
3. Export the color in `theme.dart` if needed for direct access

### Adding New Component Styles

1. Add component-specific theme data in `_createThemeData` method in `AppThemes`
2. Use the theme in your component implementation

### Adding New Theme Presets

1. Add new preset to `themePresets` map in `ThemeService`
2. The preset will automatically appear in the theme customization UI

## Future Improvements

- Animation customization options
- Component-specific theming options (cards, buttons, etc.)
- Custom font selection
- Additional color palette tools (complementary colors, etc.)
- Theme import/export functionality