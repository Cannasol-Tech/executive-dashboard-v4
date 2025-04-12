#!/bin/bash
set -e

echo "=== Deploying to DEVELOPMENT environment ==="

# Set environment
export ENVIRONMENT=development

# Navigate to project root
cd "$(dirname "$0")/.."

echo "Building Flutter web app with development configuration..."
cd flutter-app
flutter clean
flutter pub get
flutter build web --dart-define=ENVIRONMENT=development

echo "Deploying to Firebase development project..."
cd ..
firebase use development
firebase deploy --only hosting,firestore,storage,functions

echo "Development deployment complete!"
