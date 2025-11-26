#!/usr/bin/env bash
# CI coverage script - text summary only, with threshold check
# Usage: ./scripts/coverage-ci.sh [threshold_percentage]

set -e

BUILD_DIR="build"
COVERAGE_DIR="coverage"
THRESHOLD="${1:-80}"  # Default 80% minimum

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

# Determine gcov tool based on compiler (default to gcov)
GCOV_TOOL="gcov"
if [ -n "$CXX" ] && [[ "$CXX" =~ g\+\+-([0-9]+) ]]; then
  GCOV_TOOL="gcov-${BASH_REMATCH[1]}"
fi

# Capture coverage data (suppress warnings for CI)
lcov --capture --directory "$BUILD_DIR" \
  --output-file "$COVERAGE_DIR/coverage.info" \
  --gcov-tool "$GCOV_TOOL" \
  --ignore-errors inconsistent,format,mismatch \
  --quiet

# Remove system and test files from coverage
lcov --remove "$COVERAGE_DIR/coverage.info" \
  '/usr/*' \
  '*/build/_deps/*' \
  '*/tests/*' \
  '*/benchmarks/*' \
  '*/src/main.cpp' \
  --output-file "$COVERAGE_DIR/coverage.info" \
  --ignore-errors unused \
  --quiet

# Show summary
echo ""
echo "==============================="
echo "      Coverage Summary"
echo "==============================="

# Check if coverage file exists and has data
if [ ! -f "$COVERAGE_DIR/coverage.info" ] || [ ! -s "$COVERAGE_DIR/coverage.info" ]; then
    echo "⚠️  Warning: No coverage data generated"
    echo "   Coverage file not found or empty!"
    exit 0
fi

# Display summary (capture full output for better debugging)
SUMMARY_OUTPUT=$(lcov --summary "$COVERAGE_DIR/coverage.info" 2>&1)
echo "$SUMMARY_OUTPUT" | grep -E "(lines|functions)" || echo "$SUMMARY_OUTPUT"

# Extract line coverage percentage and check threshold
COVERAGE=$(echo "$SUMMARY_OUTPUT" | awk -F'[ :%]+' '/lines/ {print $3}')

if [ -z "$COVERAGE" ] || [ "$COVERAGE" = "0" ]; then
    echo ""
    echo "⚠️  Warning: Could not extract coverage percentage"
    echo "   Make sure your tests actually execute source code!"
    exit 0
fi

echo ""
echo "Line coverage: ${COVERAGE}%"
echo "Threshold: ${THRESHOLD}%"
echo ""

# Use awk for floating point comparison (bc might not be available)
if awk "BEGIN {exit !($COVERAGE < $THRESHOLD)}"; then
    echo "❌ FAILED: Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
    exit 1
else
    echo "✅ PASSED: Coverage ${COVERAGE}% meets threshold ${THRESHOLD}%"
fi
