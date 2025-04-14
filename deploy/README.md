# Cannasol Executive Dashboard - Deployment Guide

This directory contains scripts and configuration for deploying the Cannasol Executive Dashboard to different environments.

## Environment Setup

The Cannasol Executive Dashboard supports three deployment environments:

1. **Development** - For development and testing
   - URL: https://cannasol-executive-dashboard-dev.web.app
   - Firebase Project: cannasol-executive-dashboard-dev

2. **Staging** - For pre-production validation
   - URL: https://cannasol-executive-dashboard-staging.web.app
   - Firebase Project: cannasol-executive-dashboard-staging

3. **Production** - Live production environment
   - URL: https://cannasol-executive-dashboard.web.app
   - Firebase Project: cannasol-executive-dashboard

## Deployment Scripts

### Prerequisites

Before deploying, ensure you have:
- Flutter SDK installed
- Firebase CLI installed
- Firebase CLI logged in to the appropriate account
- Firebase projects created and configured

### Deploying to Development

```bash
./deploy/deploy-dev.sh
```

This script:
- Sets the environment to development
- Builds the Flutter web app with development configuration
- Deploys to the development Firebase project

### Deploying to Staging

```bash
./deploy/deploy-staging.sh
```

This script:
- Sets the environment to staging
- Builds the Flutter web app with staging configuration
- Deploys to the staging Firebase project

### Deploying to Production

```bash
./deploy/deploy-prod.sh
```

This script:
- Sets the environment to production
- Builds the Flutter web app with production configuration (release mode)
- Deploys to the production Firebase project

## Environment Configuration

Environment-specific configuration is stored in the `/flutter-app/env/` directory:

- `.env.development` - Development environment variables
- `.env.staging` - Staging environment variables
- `.env.production` - Production environment variables

These files contain settings for:
- Firebase project IDs
- API endpoints
- Feature toggles
- Performance settings

## Firebase Configuration

Firebase project configuration is managed in the `.firebaserc` file at the project root. This defines:
- Project aliases for different environments
- Hosting targets for each environment

## Security Rules

Firebase security rules are defined in:
- `/flutter-app/firestore.rules` - Firestore database security rules
- `/flutter-app/storage.rules` - Firebase Storage security rules

## Manual Deployment

If you need to deploy specific Firebase services individually:

```bash
# Deploy only hosting
firebase use [environment]
firebase deploy --only hosting

# Deploy only Firestore rules
firebase use [environment]
firebase deploy --only firestore:rules

# Deploy only Storage rules
firebase use [environment]
firebase deploy --only storage:rules

# Deploy only Cloud Functions
firebase use [environment]
firebase deploy --only functions
```

## Troubleshooting

If you encounter deployment issues:

1. **Build Errors**
   - Check Flutter dependencies: `flutter pub get`
   - Verify Firebase configuration in `firebase_options.dart`
   
2. **Deployment Errors**
   - Verify Firebase CLI login: `firebase login`
   - Check project access permissions
   - Verify project existence: `firebase projects:list`

3. **Environment Configuration**
   - Ensure environment files exist and contain correct values
   - Check that `flutter_dotenv` package is included in dependencies

For additional help, refer to:
- [Flutter Web Deployment Documentation](https://flutter.dev/docs/deployment/web)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)