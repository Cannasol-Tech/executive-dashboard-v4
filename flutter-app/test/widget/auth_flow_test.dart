import 'package:executive_dashboard/core/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:executive_dashboard/features/auth/providers/auth_provider.dart';
import 'package:executive_dashboard/features/auth/screens/login_screen.dart';
import 'package:executive_dashboard/features/dashboard/screens/dashboard_screen.dart';
import '../mocks/auth_mocks.dart';

/// A test widget that wraps a child with the necessary providers for testing
class TestApp extends StatelessWidget {
  final Widget child;
  final TestAuthService authService;

  const TestApp({
    Key? key,
    required this.child,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider.withAuthService(authService),
        ),
      ],
      child: MaterialApp(
        title: 'Test App',
        theme: ThemeData.dark(),
        home: child,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}

void main() {
  group('Authentication Flow Tests', () {
    late TestAuthService testAuthService;
    late MockSecureStorageService mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockSecureStorageService();
      testAuthService = TestAuthService(secureStorage: mockSecureStorage);
    });

    tearDown(() {
      testAuthService.dispose();
    });

    testWidgets('Login screen should render correctly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(TestApp(
        child: const LoginScreen(),
        authService: testAuthService,
      ));

      // Let the widget build
      await tester.pump();

      // Assert - verify elements are displayed
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField),
          findsAtLeastNWidgets(1)); // At least 1 text field
      expect(find.byType(ElevatedButton),
          findsAtLeastNWidgets(1)); // At least 1 button
    });

    testWidgets(
        'Login with email/password should navigate to dashboard on success',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(TestApp(
        child: const LoginScreen(),
        authService: testAuthService,
      ));

      // Act - Find email and password fields, enter credentials
      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // Find and tap the login button
      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);

      // Let the animations complete
      await tester.pumpAndSettle();

      // Assert - Verify we're navigated to dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Verify token was stored in secure storage
      final hasToken = await mockSecureStorage.hasAuthData();
      expect(hasToken, isTrue);
    });

    testWidgets('Login with invalid credentials should show error',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(TestApp(
        child: const LoginScreen(),
        authService: testAuthService,
      ));

      // Act - Find email and password fields, enter invalid credentials
      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'wrong@example.com');
      await tester.enterText(passwordField, 'wrong-password');

      // Find and tap the login button
      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);

      // Let the animations complete
      await tester.pumpAndSettle();

      // Assert - Verify error message is shown
      expect(
          find.text('Incorrect password. Please try again.'), findsOneWidget);

      // Verify we're still on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Session restoration should bypass login screen',
        (WidgetTester tester) async {
      // Arrange - set up authentication data
      await mockSecureStorage.storeAuthToken('stored-token-123');
      await mockSecureStorage.storeUserId('stored-user-123');
      await mockSecureStorage.storeUserEmail('stored@example.com');

      // Create a mock user that will be returned for the session
      final mockUser =
          MockUser(uid: 'stored-user-123', email: 'stored@example.com');
      testAuthService.emitAuthState(mockUser);

      // Build the AuthWrapper component
      await tester.pumpWidget(TestApp(
        child: AuthWrapper(child: const LoginScreen()),
        authService: testAuthService,
      ));

      // Let the authentication check complete
      await tester.pumpAndSettle();

      // Assert - Verify we're on the dashboard, not login screen
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('Signout should navigate back to login screen',
        (WidgetTester tester) async {
      // Arrange - Start with authenticated session
      await mockSecureStorage.storeAuthToken('stored-token-123');
      final mockUser =
          MockUser(uid: 'stored-user-123', email: 'stored@example.com');
      testAuthService.emitAuthState(mockUser);

      // Create widget
      await tester.pumpWidget(TestApp(
        child: const DashboardScreen(),
        authService: testAuthService,
      ));

      // Act - Find and tap the sign out button (assuming it's in the app bar or drawer)
      // This would need to be adjusted to match your actual UI
      final signOutButton = find.byIcon(Icons.logout).first;
      await tester.tap(signOutButton);

      // Let the animations complete
      await tester.pumpAndSettle();

      // Assert - Verify we're navigated back to login screen
      expect(find.byType(LoginScreen), findsOneWidget);

      // Verify token was removed from secure storage
      final hasToken = await mockSecureStorage.hasAuthData();
      expect(hasToken, isFalse);
    });
  });
}
