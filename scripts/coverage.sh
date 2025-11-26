#!/usr/bin/env bash
# Generate code coverage report
# Usage: ./scripts/coverage.sh
# Requires: gcov, lcov, genhtml

set -e

BUILD_DIR="build"
COVERAGE_DIR="coverage"

echo "Building with coverage enabled..."
cmake -B "$BUILD_DIR" -S . \
  -DCMAKE_BUILD_TYPE=Debug \
  -DENABLE_COVERAGE=ON \
  -DENABLE_TSAN=OFF

cmake --build "$BUILD_DIR" -j $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "Running tests to generate coverage data..."
cd "$BUILD_DIR"
ctest --output-on-failure
cd ..

echo "Generating coverage report..."
mkdir -p "$COVERAGE_DIR"

# Capture coverage data
lcov --capture --directory "$BUILD_DIR" --output-file "$COVERAGE_DIR/coverage.info" \
  --ignore-errors inconsistent,format

# Remove system and test files from coverage
lcov --remove "$COVERAGE_DIR/coverage.info" \
  '/usr/*' \
  '*/build/_deps/*' \
  '*/tests/*' \
  '*/benchmarks/*' \
  --output-file "$COVERAGE_DIR/coverage.info" \
  --ignore-errors unused

# Generate HTML report
genhtml "$COVERAGE_DIR/coverage.info" --output-directory "$COVERAGE_DIR/html"

echo "Coverage report generated!"
echo "Open $COVERAGE_DIR/html/index.html in your browser to view"
