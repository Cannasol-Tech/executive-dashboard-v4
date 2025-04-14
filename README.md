# Cannasol Executive Dashboard

A Flutter-based web application that serves as a user interface layer to the Firebase database and AI Agentic Cloud backend. It provides executives with analytics, email management, document management, chatbot interaction, AI task analytics, SEO controls, blog management, and customizable settings in a single cohesive, visually stunning interface.

## Project Structure

- `lib/` - Flutter application code
- `pubspec.yaml` - Flutter project configuration
- `firebase.json` - Firebase project configuration
- `functions/` - Cloud Functions for Firebase

## Getting Started

To get started with the project, follow these steps:

1. Clone the repository:

```bash
git clone https://github.com/your-username/cannasol-executive-dashboard.git
```

2. Navigate to the project directory:

```bash
cd cannasol-executive-dashboard
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:
- `functions/` - Cloud Functions for Firebase

## Running the Application

You can run the application using one of the following methods:

### Using the PowerShell Script (Recommended for Windows)

```powershell
# Show available commands
.\run.ps1

# Run the Flutter app in Chrome
.\run.ps1 run-web

# Run tests
.\run.ps1 test
```

### Using the Batch File (Alternative for Windows)

```cmd
# Show available commands
run.bat

# Run the Flutter app in Chrome
run.bat run-web

# Run tests
run.bat test
```

### Using Make (Unix/Linux/macOS)

```bash
# Show available commands
make

# Run the Flutter app in Chrome
make run-web

# Run tests
make test
```

## Available Commands

- `run-web` - Run the Flutter app in Chrome
- `run-mobile` - Run the Flutter app on a connected mobile device
- `build-web` - Build the Flutter app for web deployment
- `test` - Run all tests
- `test-unit` - Run unit tests
- `test-widget` - Run widget tests
- `clean` - Clean build artifacts
- `deps` - Get dependencies
- `analyze` - Run Flutter analyze
- `format` - Format code

## Development

### Project Overview

The Cannasol Technologies Executive Dashboard is designed to:

1. Display data from Firebase beautifully and intuitively
2. Capture user input and store it in Firebase
3. Show results and updates as backend AI agents process the data
4. Provide visual feedback on process status

### Implementation Approach

The project follows a phased release strategy:

- **MVP (Minimum Viable Product):** Initial release with core functionality
- **v2:** Enhanced features and additional capabilities
- **v3:** Complete feature set and refinements

### Key Features

- Dashboard with analytics overview
- User authentication with Google Sign-in
- Email management with AI-assisted responses
- Document viewer and downloader
- AI chatbot interface
- AI task analytics
- SEO management tools
- Blog content management
- Customizable settings
# executive-dashboard-v4
