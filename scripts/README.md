# Scripts

Convenience scripts for common development tasks. Think of these like npm scripts!

## Available Scripts

### `./scripts/build.sh [mode]`

Build the project with different configurations.

**Modes:**
- `debug` - Debug build with debug symbols
- `release` - Optimized release build (default)
- `tsan` - Debug build with Thread Sanitizer enabled

**Examples:**
```bash
./scripts/build.sh           # Release build
./scripts/build.sh debug     # Debug build
./scripts/build.sh tsan      # Build with TSAN
```

### `./scripts/test.sh [mode]`

Build (if needed) and run all tests.

**Modes:**
- `debug` - Run tests in debug mode
- `release` - Run tests in release mode (default)
- `tsan` - Run tests with Thread Sanitizer (useful for detecting race conditions!)

**Examples:**
```bash
./scripts/test.sh           # Release build tests
./scripts/test.sh debug     # Debug build tests
./scripts/test.sh tsan      # Tests with Thread Sanitizer
```

### `./scripts/run.sh [mode]`

Run the demo executable.

Automatically builds if needed, then runs the main executable without having to navigate into the build directory.

**Modes:**
- `debug` - Run demo in debug mode
- `release` - Run demo in release mode (default)
- `tsan` - Run demo with Thread Sanitizer

**Examples:**
```bash
./scripts/run.sh           # Release build
./scripts/run.sh debug     # Debug build
./scripts/run.sh tsan      # Run with Thread Sanitizer
```

### `./scripts/benchmark.sh [args...]`

Run benchmarks with optional arguments.

Automatically builds if needed. You can pass any Google Benchmark arguments.

```bash
./scripts/benchmark.sh                    # Run all benchmarks
./scripts/benchmark.sh --help             # Show benchmark options
./scripts/benchmark.sh --benchmark_filter=MyTest  # Run specific benchmark
./scripts/benchmark.sh --benchmark_min_time=1s    # Run for at least 1 second
```

### `./scripts/clean.sh`

Remove build artifacts and coverage data.

```bash
./scripts/clean.sh
```

### `./scripts/coverage.sh`

Generate detailed HTML coverage report (for local development).

**Requirements:**
- `gcov` (usually comes with GCC)
- `lcov` - Install with: `brew install lcov` or `apt install lcov`

**Output:**
Creates an HTML coverage report in `coverage/html/index.html`

**Use case:** Local development - see exactly which lines aren't covered

```bash
./scripts/coverage.sh
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### `./scripts/coverage-ci.sh [threshold]`

Generate coverage summary with threshold check (for CI/CD).

**Arguments:**
- `threshold` - Minimum line coverage percentage (default: 80)

**Output:**
- Text summary only (no HTML)
- Exits with error if coverage below threshold
- Creates `coverage/coverage.info` for uploading to services

**Use case:** CI/CD - fail builds if coverage too low

```bash
./scripts/coverage-ci.sh     # Requires 80% coverage
./scripts/coverage-ci.sh 70  # Requires 70% coverage
./scripts/coverage-ci.sh 90  # Requires 90% coverage
```

**Example output:**
```
Line coverage: 85.2%
Threshold: 80%
✅ PASSED: Coverage 85.2% meets threshold 80%
```

## Why Scripts?

These scripts make development faster by:
- Hiding complex CMake commands
- Providing consistent workflows
- Being easy to remember and type
- Similar to `npm run` scripts you might be familiar with!
