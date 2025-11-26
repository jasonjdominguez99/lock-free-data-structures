#!/usr/bin/env bash
# Clean build artifacts
# Usage: ./scripts/clean.sh

set -e

BUILD_DIR="build"

if [ -d "$BUILD_DIR" ]; then
  echo "Removing build directory..."
  rm -rf "$BUILD_DIR"
  echo "Build directory removed!"
else
  echo "Build directory not found, nothing to clean."
fi

# Also clean coverage files if they exist
if [ -d "coverage" ]; then
  echo "Removing coverage directory..."
  rm -rf coverage
fi

echo "Clean complete!"
