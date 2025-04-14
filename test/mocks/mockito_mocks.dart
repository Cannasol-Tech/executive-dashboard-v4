import 'package:mockito/annotations.dart';
import 'package:executive_dashboard/features/auth/services/auth_service_interface.dart';
import 'package:executive_dashboard/core/services/secure_storage_service.dart';

// Use the @GenerateMocks annotation to specify which classes to mock
@GenerateMocks(
  [
    AuthServiceInterface,
    SecureStorageService,
  ],
  // Use customMocks to avoid naming conflicts with existing mocks
  customMocks: [
    MockSpec<AuthServiceInterface>(as: #MockAuthService),
    MockSpec<SecureStorageService>(as: #MockSecureStorage),
  ],
)
// This will generate MockAuthService and MockSecureStorage classes
void main() {}