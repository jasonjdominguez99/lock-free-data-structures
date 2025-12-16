#!/usr/bin/env bash
# Run tests for the project
# Usage: ./scripts/test.sh [debug|debug-tsan|release]

set -e

# Default to debug build (with ASAN + UBSAN)
BUILD_TYPE="${1:-debug}"
BUILD_DIR="build"

# Build if needed
if [ ! -d "$BUILD_DIR" ]; then
  echo "Build directory not found. Running build first..."
  ./scripts/build.sh "$BUILD_TYPE"
fi

echo "Running tests..."
cd "$BUILD_DIR"
ctest --output-on-failure

echo "All tests passed!"
