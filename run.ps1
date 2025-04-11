# PowerShell script for running Flutter commands from the root directory

param (
    [Parameter(Position=0)]
    [string]$Command = "help"
)

# Variables
$FLUTTER_APP_DIR = "flutter-app"
$FLUTTER = "flutter"

# Functions
function Show-Help {
    Write-Host "Available commands:"
    Write-Host "  run-web     - Run the Flutter app in Chrome"
    Write-Host "  run-mobile  - Run the Flutter app on a connected mobile device"
    Write-Host "  build-web   - Build the Flutter app for web deployment"
    Write-Host "  test        - Run all tests"
    Write-Host "  test-unit   - Run unit tests"
    Write-Host "  test-widget - Run widget tests"
    Write-Host "  clean       - Clean build artifacts"
    Write-Host "  deps        - Get dependencies"
    Write-Host "  analyze     - Run Flutter analyze"
    Write-Host "  format      - Format code"
}

function Run-FlutterCommand {
    param (
        [string]$FlutterCommand
    )
    
    Push-Location $FLUTTER_APP_DIR
    try {
        Invoke-Expression "$FLUTTER $FlutterCommand"
    }
    finally {
        Pop-Location
    }
}

# Command handling
switch ($Command) {
    "run-web" {
        Run-FlutterCommand "run -d chrome"
    }
    "run-mobile" {
        Run-FlutterCommand "run"
    }
    "build-web" {
        Run-FlutterCommand "build web"
    }
    "test" {
        Run-FlutterCommand "test"
    }
    "test-unit" {
        Run-FlutterCommand "test test/unit/"
    }
    "test-widget" {
        Run-FlutterCommand "test test/widget/"
    }
    "clean" {
        Run-FlutterCommand "clean"
    }
    "deps" {
        Run-FlutterCommand "pub get"
    }
    "analyze" {
        Run-FlutterCommand "analyze"
    }
    "format" {
        Run-FlutterCommand "format ."
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "Unknown command: $Command"
        Show-Help
    }
} 