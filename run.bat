@echo off
rem Batch file for running Flutter commands from the root directory

set FLUTTER_APP_DIR=flutter-app
set FLUTTER=flutter

if "%1"=="" goto help

if "%1"=="run-web" goto run-web
if "%1"=="run-mobile" goto run-mobile
if "%1"=="build-web" goto build-web
if "%1"=="test" goto test
if "%1"=="test-unit" goto test-unit
if "%1"=="test-widget" goto test-widget
if "%1"=="clean" goto clean
if "%1"=="deps" goto deps
if "%1"=="analyze" goto analyze
if "%1"=="format" goto format
if "%1"=="help" goto help

echo Unknown command: %1
goto help

:run-web
cd %FLUTTER_APP_DIR% && %FLUTTER% run -d chrome
goto end

:run-mobile
cd %FLUTTER_APP_DIR% && %FLUTTER% run
goto end

:build-web
cd %FLUTTER_APP_DIR% && %FLUTTER% build web
goto end

:test
cd %FLUTTER_APP_DIR% && %FLUTTER% test
goto end

:test-unit
cd %FLUTTER_APP_DIR% && %FLUTTER% test test/unit/
goto end

:test-widget
cd %FLUTTER_APP_DIR% && %FLUTTER% test test/widget/
goto end

:clean
cd %FLUTTER_APP_DIR% && %FLUTTER% clean
goto end

:deps
cd %FLUTTER_APP_DIR% && %FLUTTER% pub get
goto end

:analyze
cd %FLUTTER_APP_DIR% && %FLUTTER% analyze
goto end

:format
cd %FLUTTER_APP_DIR% && %FLUTTER% format .
goto end

:help
echo Available commands:
echo   run-web     - Run the Flutter app in Chrome
echo   run-mobile  - Run the Flutter app on a connected mobile device
echo   build-web   - Build the Flutter app for web deployment
echo   test        - Run all tests
echo   test-unit   - Run unit tests
echo   test-widget - Run widget tests
echo   clean       - Clean build artifacts
echo   deps        - Get dependencies
echo   analyze     - Run Flutter analyze
echo   format      - Format code
goto end

:end 