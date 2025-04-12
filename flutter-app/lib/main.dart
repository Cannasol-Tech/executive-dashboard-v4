import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'shared/theme/theme_provider.dart';
import 'features/settings/screens/theme_customization_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the theme system
  await initializeTheme();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the app with providers
    return MultiProvider(
      providers: [
        // Theme provider
        createThemeProvider(),
        // Add other providers here as needed
      ],
      child: const AppWithTheme(),
    );
  }
}

class AppWithTheme extends StatelessWidget {
  const AppWithTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Cannasol Executive Dashboard',
      debugShowCheckedModeBanner: false,
      
      // Apply theme mode (light, dark, system)
      themeMode: themeProvider.themeMode,
      
      // Define theme based on current settings 
      theme: themeProvider.getActiveTheme(context),
      
      // Define dark theme based on current settings
      darkTheme: themeProvider.getActiveTheme(
        context,
      ),
      
      // Home screen
      home: const HomeScreen(),
    );
  }
}

/// Temporary home screen for demonstration
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cannasol Executive Dashboard'),
        actions: [
          // Theme customization button
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ThemeCustomizationScreen(),
                ),
              );
            },
            tooltip: 'Customize Theme',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Cannasol Executive Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spaceLarge),
            Text(
              'This dashboard provides analytics insights, email management, chat capabilities, SEO controls, blog management, and customizable settings',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spaceLarge * 2),
            ElevatedButton.icon(
              icon: const Icon(Icons.color_lens),
              label: const Text('Customize Theme'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThemeCustomizationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: spaceMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureCard(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  color: emeraldGleam,
                ),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  color: royalAzure,
                ),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.chat_outlined,
                  title: 'Chat',
                  color: deepOcean,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a feature card for the dashboard
  Widget _buildFeatureCard({
    required BuildContext context, 
    required IconData icon, 
    required String title,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.all(spaceTiny),
      child: Padding(
        padding: const EdgeInsets.all(spaceMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: spaceTiny),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
