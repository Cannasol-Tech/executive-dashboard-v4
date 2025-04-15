import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'shared/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'config/theme.dart';
import 'firebase_options.dart';
import 'core/services/env_config_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/email/providers/email_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_summary_provider.dart';
import 'features/analysis/providers/analysis_data_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/analysis/screens/analysis_screen.dart';
import 'features/email/screens/email_inbox_screen.dart';
import 'features/shared/screens/coming_soon_screen.dart';
import 'features/document_generator/screens/documents_screen.dart'; 
import 'features/document_generator/providers/document_generator_provider.dart';
import 'features/auth/services/auth_service.dart'; // Added import for AuthService
import 'core/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      name: 'cannasolDashboard',
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    print('Firebase initialized successfully with name: cannasolDashboard');

    // Initialize environment configuration
    final env = EnvConfigService();
    await env.initialize(env: kReleaseMode ? 'production' : 'development');
    print('Environment configuration initialized: [32m${env.currentEnvironment}[0m');
  } catch (e) {
    print('Failed to initialize services: $e');
  }

  // Initialize the theme system
  await initializeTheme();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({Key? key, this.firebaseInitialized = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardSummaryProvider(firebaseInitialized: firebaseInitialized)),
        ChangeNotifierProvider(create: (_) => AnalysisDataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
        ChangeNotifierProvider(create: (_) => EmailProvider()),
        Provider<AppTheme>(create: (_) => AppTheme()), 
        // Add AuthService provider
        Provider<AuthService>(create: (_) => AuthService()),
        // Add DocumentGeneratorProvider with dependency on UserModel
        ProxyProvider<AuthService, DocumentGeneratorProvider>(
          update: (_, authService, __) => DocumentGeneratorProvider(
            currentUser: authService.currentUser
          ),
        ),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Cannasol Executive Dashboard',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.getActiveTheme(context),
            initialRoute: '/',
            routes: {
              '/': (context) => firebaseInitialized
                  ? AuthWrapper(child: const DashboardScreen())
                  : const FirebaseErrorScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/dashboard': (context) => AuthWrapper(child: const DashboardScreen()),
              '/analysis': (context) => AuthWrapper(child: const AnalysisScreen()),
              '/email': (context) => AuthWrapper(child: const EmailInboxScreen()),
              '/documents': (context) => AuthWrapper(child: const DocumentsScreen()), 
              '/chat': (context) => AuthWrapper(child: const ComingSoonScreen(featureName: 'Chat Interface')),
              '/ai-tasks': (context) => AuthWrapper(child: const ComingSoonScreen(featureName: 'AI Task Analytics')),
              '/seo': (context) => AuthWrapper(child: const ComingSoonScreen(featureName: 'SEO Management')),
              '/blog': (context) => AuthWrapper(child: const ComingSoonScreen(featureName: 'Blog Management')),
              '/settings': (context) => AuthWrapper(child: const ComingSoonScreen(featureName: 'Settings')),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget that handles authentication state
  /// A wrapper widget that handles authentication state
  /// and directs users to either the login screen or the child widget
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check session status when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final hasSession = await authProvider.checkSession();

      if (!hasSession && mounted) {
        // Navigate to login if no active session
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (hasSession && mounted) {
        // If we have a session, route to the current path or dashboard
        _routeToCurrentPath(context);
      }
    } catch (e) {
      print('Error checking session: $e');
      if (mounted) {
        // If there's an error checking the session, navigate to login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _routeToCurrentPath(BuildContext context) {
    if (kIsWeb) {
      // Get the current path from the browser URL
      final uri = Uri.parse(Uri.base.toString());
      final path = uri.path;

      // Get all defined routes
      final routes = ModalRoute.of(context)?.settings.name != '/'
          ? null // We're already on a route
          : (context.findAncestorWidgetOfExactType<MaterialApp>()
                  as MaterialApp)
              .routes
              ?.keys
              .toList();

      if (routes != null &&
          path.isNotEmpty &&
          path != '/' &&
          routes.contains(path)) {
        // If the path matches a defined route, navigate to it
        print('Routing to path: $path');
        Navigator.of(context).pushReplacementNamed(path);
      } else {
        // Default to dashboard
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      // For non-web platforms, just go to dashboard
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading spinner while checking authentication
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate based on authentication status
    if (authProvider.isAuthenticated) {
  // Start Firestore listeners only after login
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<AnalysisDataProvider>(context, listen: false).maybeStartListening(context);
    Provider.of<DashboardSummaryProvider>(context, listen: false).maybeStartFetching(context);
  });
  return const DashboardScreen();
} else {
  // Optionally stop listeners on logout
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<AnalysisDataProvider>(context, listen: false).maybeStartListening(context);
    Provider.of<DashboardSummaryProvider>(context, listen: false).maybeStartFetching(context);
  });
  return const LoginScreen();
}
  }
}

/// Error screen shown when Firebase fails to initialize
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepOcean,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              const Text(
                'Firebase Connection Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to connect to Firebase. Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app by popping to first route and rebuilding
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGleam,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cannasol Executive Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Added a Container with a colored background as a placeholder
            Container(
              width: 100,
              height: 100,
              color: Colors.green,
              margin: const EdgeInsets.only(bottom: 20),
              child: const Center(
                child: Text('Logo', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Text(
              'Executive Dashboard',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Cannasol Technologies',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            const Text(
              'Dashboard Setup in Progress...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Placeholder for login functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Login functionality coming soon')),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
