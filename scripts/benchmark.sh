#!/usr/bin/env bash
# Run benchmarks
# Usage: ./scripts/benchmark.sh [build_type] [benchmark_args...]
# Build type can be: debug, debug-tsan, release (default: release)

set -e

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
  echo "Usage: ./scripts/benchmark.sh [build_type] [benchmark_args...]"
  echo ""
  echo "Build type can be: debug, debug-tsan, release (default: release)"
  echo ""
  echo "Builds and runs benchmarks. Benchmarks are NOT built by regular build scripts"
  echo "to save compile time - they're only built when you run this script."
  echo ""
  echo "Common benchmark arguments:"
  echo "  --benchmark_filter=<regex>       Run only benchmarks matching the regex"
  echo "  --benchmark_min_time=<time>      Minimum time to run each benchmark"
  echo "  --benchmark_repetitions=<n>      Number of times to repeat each benchmark"
  echo "  --benchmark_format=<format>      Output format (console|json|csv)"
  echo "  --benchmark_out=<file>           Write results to file"
  echo ""
  echo "Examples:"
  echo "  ./scripts/benchmark.sh                           # Build and run with release"
  echo "  ./scripts/benchmark.sh debug                     # Build and run with debug"
  echo "  ./scripts/benchmark.sh release --benchmark_filter=MyBench"
  echo ""
  echo "For full benchmark options, run: ./scripts/benchmark.sh --benchmark_help"
  exit 0
fi

BUILD_DIR="build"

# Parse build type if provided
BUILD_TYPE="release"
BENCHMARK_ARGS=()

if [[ "$1" == "debug" ]] || [[ "$1" == "debug-tsan" ]] || [[ "$1" == "release" ]]; then
  BUILD_TYPE="$1"
  shift
fi

# Remaining arguments are benchmark arguments
BENCHMARK_ARGS=("$@")

# Check if benchmarks need to be built
if [ ! -f "$BUILD_DIR/benchmarks/lock_free_data_structures_benchmark" ]; then
  echo "Benchmarks not found. Building with BUILD_BENCHMARKS=ON..."

  # Build with benchmarks enabled using build.sh, then reconfigure with benchmarks
  ./scripts/build.sh "$BUILD_TYPE"

  # Reconfigure to enable benchmarks
  cd "$BUILD_DIR"
  cmake . -DBUILD_BENCHMARKS=ON
  cmake --build . -j $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
  cd ..
fi

echo "Running benchmarks..."
"$BUILD_DIR/benchmarks/lock_free_data_structures_benchmark" "${BENCHMARK_ARGS[@]}"
