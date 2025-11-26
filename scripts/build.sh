#!/usr/bin/env bash
# Build script for the project
# Usage: ./scripts/build.sh [debug|release|tsan|tsan-release]

set -e

# Default to Release build
BUILD_TYPE="${1:-release}"
BUILD_DIR="build"

case "$BUILD_TYPE" in
  debug)
    echo "Building in Debug mode..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=Debug \
      -DENABLE_TSAN=OFF
    ;;
  release)
    echo "Building in Release mode..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=Release \
      -DENABLE_TSAN=OFF
    ;;
  tsan)
    echo "Building with Thread Sanitizer..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=Debug \
      -DENABLE_TSAN=ON
    ;;
  tsan-release)
    echo "Building with Thread Sanitizer (optimized with debug info)..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DENABLE_TSAN=ON
    ;;
  *)
    echo "Usage: $0 [debug|release|tsan|tsan-release]"
    exit 1
    ;;
esac

# Build with all available cores
cmake --build "$BUILD_DIR" -j $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "Build complete! Binaries in $BUILD_DIR/"
