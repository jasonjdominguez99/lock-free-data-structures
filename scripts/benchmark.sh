#!/usr/bin/env bash
# Run benchmarks
# Usage: ./scripts/benchmark.sh [benchmark_args...]

set -e

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
  echo "Usage: ./scripts/benchmark.sh [benchmark_args...]"
  echo ""
  echo "Runs the benchmark suite. If benchmarks are not built, they will be built first."
  echo ""
  echo "Common benchmark arguments:"
  echo "  --help                           Show benchmark help"
  echo "  --benchmark_filter=<regex>       Run only benchmarks matching the regex"
  echo "  --benchmark_min_time=<time>      Minimum time to run each benchmark"
  echo "  --benchmark_repetitions=<n>      Number of times to repeat each benchmark"
  echo "  --benchmark_format=<format>      Output format (console|json|csv)"
  echo "  --benchmark_out=<file>           Write results to file"
  echo ""
  echo "For full benchmark options, run: ./scripts/benchmark.sh --benchmark_help"
  exit 0
fi

BUILD_DIR="build"

if [ ! -f "$BUILD_DIR/benchmarks/hello_world_benchmark" ]; then
  echo "Benchmark not found. Building..."
  ./scripts/build.sh
fi

echo "Running benchmarks..."
"$BUILD_DIR/benchmarks/hello_world_benchmark" "$@"
