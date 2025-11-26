#!/usr/bin/env bash
# Run the demo executable
# Usage: ./scripts/run.sh [debug|release|tsan|tsan-release]

set -e

# Default to Release build
BUILD_TYPE="${1:-release}"
BUILD_DIR="build"

if [ ! -f "$BUILD_DIR/hello_world_demo" ]; then
  echo "Demo not found. Building..."
  ./scripts/build.sh "$BUILD_TYPE"
fi

echo "Running demo..."
"$BUILD_DIR/hello_world_demo"
