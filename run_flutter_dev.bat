@echo off
echo Starting Cannasol Executive Dashboard in development mode...
echo.
echo This will launch the app with hot reload enabled.
echo Press 'r' in the terminal to hot reload after making changes.
echo Press 'R' in the terminal to hot restart the entire app.
echo Press 'q' to quit.
echo.

cd flutter-app

:: Check if running in Chrome is specifically requested
if "%1"=="chrome" (
  echo Running in Chrome...
  flutter run -d chrome --web-renderer html
) else (
  :: Check for connected devices
  for /f "tokens=*" %%a in ('flutter devices') do (
    echo Detected: %%a
  )
  echo.
  echo Choose a device to run on or press Enter to run on Chrome:
  set /p device=
  
  if "%device%"=="" (
    echo Running in Chrome...
    flutter run -d chrome --web-renderer html
  ) else (
    echo Running on selected device: %device%
    flutter run -d %device%
  )
)

echo.
echo Development session ended.
echo To start again, run this script.
pause 