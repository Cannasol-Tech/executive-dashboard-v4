import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// A wrapper widget that handles authentication state
/// and directs users to either the login screen or the child widget
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context);

    // For now, always show the child since we're initializing the app
    // Later, this would check authentication state and redirect if needed
    return child;

    // Uncomment once auth functionality is implemented
    /*
    return authProvider.isAuthenticated
        ? child
        : const LoginScreen();
    */
  }
}
