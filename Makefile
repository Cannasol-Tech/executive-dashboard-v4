# Makefile for Cannasol Executive Dashboard

# Variables
FLUTTER_APP_DIR := flutter-app
FLUTTER := flutter

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  run-web     - Run the Flutter app in Chrome"
	@echo "  run-mobile  - Run the Flutter app on a connected mobile device"
	@echo "  build-web   - Build the Flutter app for web deployment"
	@echo "  test        - Run all tests"
	@echo "  test-unit   - Run unit tests"
	@echo "  test-widget - Run widget tests"
	@echo "  clean       - Clean build artifacts"
	@echo "  deps        - Get dependencies"
	@echo "  analyze     - Run Flutter analyze"
	@echo "  format      - Format code"

# Flutter targets
.PHONY: run-web
run-web:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) run -d chrome

.PHONY: run-mobile
run-mobile:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) run

.PHONY: build-web
build-web:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) build web

.PHONY: test
test:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) test

.PHONY: test-unit
test-unit:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) test test/unit/

.PHONY: test-widget
test-widget:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) test test/widget/

.PHONY: clean
clean:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) clean

.PHONY: deps
deps:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) pub get

.PHONY: analyze
analyze:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) analyze

.PHONY: format
format:
	cd $(FLUTTER_APP_DIR) && $(FLUTTER) format . 