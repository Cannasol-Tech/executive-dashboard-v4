# Running Cannasol Executive Dashboard with Hot Reload

This guide explains how to run the Flutter application with hot reload enabled, which allows you to see your changes in real-time as you modify the code.

## What is Hot Reload/Restart?

- **Hot Reload (r)**: Updates the UI with code changes while preserving the app state
- **Hot Restart (R)**: Completely restarts the app, showing all code changes but losing app state

## Prerequisites

- Flutter SDK installed
- A development environment (VS Code, Android Studio, etc.)
- A web browser (Chrome recommended) or a connected mobile device

## Running the App with Hot Reload

### Windows

1. Double-click the `run_flutter_dev.bat` file in the project root
2. Choose a device when prompted, or press Enter to run in Chrome
3. Wait for the app to build and launch

### macOS/Linux

1. Open Terminal and navigate to the project root
2. Make the script executable (first time only):
   ```
   chmod +x run_flutter_dev.sh
   ```
3. Run the script:
   ```
   ./run_flutter_dev.sh
   ```
4. Choose a device when prompted, or press Enter to run in Chrome
5. Wait for the app to build and launch

## Using Hot Reload During Development

Once the app is running:

1. Make changes to your Flutter code in your editor
2. Save the file(s)
3. In the terminal where the app is running:
   - Press `r` to hot reload (preserves app state)
   - Press `R` to hot restart (completely restarts the app)
   - Press `q` to quit the app

## Tips for Effective Hot Reload

- Not all changes are visible with hot reload (like certain global variables or app initialization code)
- If you don't see changes after hot reload, try a hot restart with `R`
- Hot reload works best for UI changes and stateless widgets
- If hot reload doesn't work properly, stop the app and run it again

## Common Issues

- **"No connected devices found"**: Make sure a device is connected or an emulator is running
- **Web version looks different**: Web rendering can differ from mobile rendering
- **Hot reload not showing changes**: Some changes require a hot restart (`R`) or a full restart

## Specific Instructions for This Project

- The login screen uses the `assets/icn/cannasol-logo.png` image, make sure this file exists
- To test authentication, create a Firebase project and update the `firebase_options.dart` file
- Configuration changes in `firebase_options.dart` require a full app restart 