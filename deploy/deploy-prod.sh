#!/bin/bash
set -e

echo "=== Deploying to PRODUCTION environment ==="

# Set environment
export ENVIRONMENT=production

# Navigate to project root
cd "$(dirname "$0")/.."

echo "Building Flutter web app with production configuration..."
cd flutter-app
flutter clean
flutter pub get
flutter build web --release --dart-define=ENVIRONMENT=production

echo "Deploying to Firebase production project..."
cd ..
firebase use production
firebase deploy --only hosting,firestore,storage,functions

echo "Production deployment complete!"