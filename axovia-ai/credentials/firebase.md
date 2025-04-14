# Firebase Configuration Template

## Firebase Web Configuration

```dart
// File: lib/firebase_options.dart
// Replace these placeholder values with your actual Firebase configuration

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the current platform
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Add other platforms here if needed
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDrT5mpA6vLHeTKQcClk_xD4yA8GXCUO7s",
    authDomain: "cannasol-executive-dashboard.firebaseapp.com",
    projectId: "cannasol-executive-dashboard",
    storageBucket: "cannasol-executive-dashboard.firebasestorage.app",
    messagingSenderId: "307711515061",
    appId: "1:307711515061:web:ec1d42ff947e71d06a21fc",
    measurementId: "G-V49KE73S2R"
    databaseURL: 'https://cannasol-executive-dashboard-default-rtdb.firebaseio.com',  
  );
}
```

## How to Get These Values

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select the "cannasol-executive-dashboard" project
3. Click on the web app configuration (⚙️ icon)
4. Under "Your apps," select the web app
5. In "SDK setup and configuration," choose "Config" to see all the required values

## Additional Required Configuration

### Firestore Rules

Please also provide Firestore security rules if you have specific requirements. Default rules template:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Authentication Settings

Please confirm:
- Which authentication providers should be enabled (Google Sign-in already confirmed)
- Any domain restrictions for authentication
- Admin user email addresses that should have elevated permissions
