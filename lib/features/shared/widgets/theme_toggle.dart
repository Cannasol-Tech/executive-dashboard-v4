import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme_provider.dart';
import '../../../config/app_theme.dart'; // Updated import

class ThemeToggle extends StatelessWidget {
  final bool showLabel;

  const ThemeToggle({
    Key? key,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: themeProvider.isDarkMode
                ? AppTheme.moonlight
                : AppTheme.deepOcean,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
          tooltip: themeProvider.isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
        ),
      ],
    );
  }
}
