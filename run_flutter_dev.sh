#!/bin/bash

echo "Starting Cannasol Executive Dashboard in development mode..."
echo
echo "This will launch the app with hot reload enabled."
echo "Press 'r' in the terminal to hot reload after making changes."
echo "Press 'R' in the terminal to hot restart the entire app."
echo "Press 'q' to quit."
echo

cd flutter-app

# Check if running in Chrome is specifically requested
if [ "$1" = "chrome" ]; then
  echo "Running in Chrome..."
  flutter run -d chrome --web-renderer html
else
  # Check for connected devices
  echo "Available devices:"
  flutter devices
  echo
  echo "Choose a device to run on or press Enter to run on Chrome:"
  read device
  
  if [ -z "$device" ]; then
    echo "Running in Chrome..."
    flutter run -d chrome --web-renderer html
  else
    echo "Running on selected device: $device"
    flutter run -d "$device"
  fi
fi

echo
echo "Development session ended."
echo "To start again, run this script." 