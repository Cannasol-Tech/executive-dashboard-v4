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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            Provider.of<ThemeProvider>(context).isDarkMode ? 'Dark Mode' : 'Light Mode',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
                ? AppTheme.moonlight
                : AppTheme.deepOcean,
          ),
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false ).toggleTheme();
          },
          tooltip: Provider.of<ThemeProvider>(context).isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
        ),
      ],
    );
  }
}
