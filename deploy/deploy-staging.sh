#!/bin/bash
set -e

echo "=== Deploying to STAGING environment ==="

# Set environment
export ENVIRONMENT=staging

# Navigate to project root
cd "$(dirname "$0")/.."

echo "Building Flutter web app with staging configuration..."
cd flutter-app
flutter clean
flutter pub get
flutter build web --dart-define=ENVIRONMENT=staging

echo "Deploying to Firebase staging project..."
cd ..
firebase use staging
firebase deploy --only hosting,firestore,storage,functions

echo "Staging deployment complete!"