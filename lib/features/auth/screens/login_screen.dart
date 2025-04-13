import 'package:executive_dashboard/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Login screen for the Cannasol Executive Dashboard
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegistering = false;
  bool _isPasswordVisible = false;
  bool _isResetPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.deepOcean,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.deepOcean,
              Color.lerp(AppTheme.deepOcean, AppTheme.royalAzure, 0.2) ??
                  AppTheme.deepOcean,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Company Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icn/cannasol-logo.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Cannasol Technologies',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Executive Dashboard',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.slate,
                                  ),
                        ),
                        const SizedBox(height: 32),

                        if (_isResetPassword)
                          _buildPasswordResetForm(authProvider)
                        else
                          _buildEmailPasswordForm(authProvider),

                        if (authProvider.isLoading) ...[
                          const SizedBox(height: 24),
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.emeraldGleam),
                          ),
                        ],

                        if (authProvider.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              authProvider.errorMessage ?? '',
                              style: TextStyle(
                                color: Colors.red.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPasswordForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display Name field (only for registration)
          if (_isRegistering) ...[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (_isRegistering && (value == null || value.isEmpty)) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (_isRegistering && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Action button (Login or Register)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalAzure,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: authProvider.isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm(authProvider);
                    }
                  },
            child: Text(
              _isRegistering ? 'Create Account' : 'Sign In',
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),

          // Toggle between login and register
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                });
              },
              child: Text(
                _isRegistering
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Create one',
                style: TextStyle(color: AppTheme.royalAzure),
              ),
            ),
          ),

          // Forgot password link
          if (!_isRegistering)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isResetPassword = true;
                  });
                },
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(color: AppTheme.slate),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Reset Your Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.slate),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.royalAzure,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: authProvider.isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm(authProvider);
                    }
                  },
            child: const Text(
              'Send Reset Link',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isResetPassword = false;
                });
              },
              child: Text(
                'Back to Sign In',
                style: TextStyle(color: AppTheme.slate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm(AuthProvider authProvider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_isResetPassword) {
      authProvider.resetPassword(email);
    } else if (_isRegistering) {
      try {
        await authProvider.createUserWithEmailAndPassword(
            email, password, name);
        if (mounted && authProvider.isAuthenticated) {
          _routeToDestination(context);
        }
      } catch (e) {
        // Error is already handled by the provider
      }
    } else {
      try {
        await authProvider.loginWithEmailAndPassword(email, password);
        if (mounted && authProvider.isAuthenticated) {
          _routeToDestination(context);
        }
      } catch (e) {
        // Error is already handled by the provider
      }
    }
  }

  void _routeToDestination(BuildContext context) {
    // Check if we need to route to a specific path
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Go back to previous screen if possible
    } else {
      // Check current URL path for web
      if (Uri.base.path.isNotEmpty &&
          Uri.base.path != '/' &&
          Uri.base.path != '/login') {
        print('Routing to path: ${Uri.base.path}');
        Navigator.pushReplacementNamed(context, Uri.base.path);
      } else {
        // Default route to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }
}
