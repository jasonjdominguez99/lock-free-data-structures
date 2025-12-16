#!/usr/bin/env bash
# Run the demo executable
# Usage: ./scripts/run.sh [debug|debug-tsan|release]

set -e

# Default to debug build
BUILD_TYPE="${1:-debug}"
BUILD_DIR="build"

if [ ! -f "$BUILD_DIR/lock_free_data_structures_demo" ]; then
  echo "Demo not found. Building..."
  ./scripts/build.sh "$BUILD_TYPE"
fi

echo "Running demo..."
"$BUILD_DIR/lock_free_data_structures_demo"
