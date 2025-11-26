# C++ Project Template

[![CI](https://github.com/jasonjdominguez99/modern-cpp-project-template/actions/workflows/ci.yml/badge.svg)](https://github.com/jasonjdominguez99/modern-cpp-project-template)
[![codecov](https://codecov.io/gh/jasonjdominguez99/modern-cpp-project-template/branch/main/graph/badge.svg)](https://codecov.io/gh/jasonjdominguez99/modern-cpp-project-template)

> **TODO for template users:** Update the badge URLs above (lines 3-4) to point to your own repository. Replace `jasonjdominguez99/modern-cpp-project-template` with your GitHub username and repository name.

A modern C++23 project template with best practices, testing, benchmarking, and CI/CD.

## Features

- **C++23 Standard** - Latest C++ features
- **Modern CMake** (3.25+) - Clean, maintainable build system
- **Google Test** - Unit testing framework
- **Google Benchmark** - Performance benchmarking
- **Thread Sanitizer** - Race condition detection
- **Code Coverage** - Track test coverage
- **clang-format** - Automatic code formatting (Google C++ style)
- **pre-commit hooks** - Enforce code quality
- **GitHub Actions CI** - Automated testing on Linux & macOS
- **Convenience scripts** - npm-style build scripts

## Quick Start

### Prerequisites

- CMake 3.25+
- C++23 compatible compiler:
  - GCC 14+ or Clang 16+
  - On macOS: Homebrew LLVM recommended (`brew install llvm`)
- (Optional) lcov for coverage reports: `brew install lcov` / `apt install lcov`
- (Optional) Doxygen for API documentation: `brew install doxygen` / `apt install doxygen`

### Build & Run

```bash
# Build (Release mode)
./scripts/build.sh

# Run the demo
./scripts/run.sh

# Run tests
./scripts/test.sh

# Run benchmarks
./scripts/benchmark.sh

# Clean build artifacts
./scripts/clean.sh
```

### Build Modes

```bash
./scripts/build.sh release  # Optimized build (default)
./scripts/build.sh debug    # Debug symbols
./scripts/build.sh tsan     # Thread Sanitizer
```

## Development

### Running Tests

```bash
./scripts/test.sh
```

Or manually:
```bash
cmake -B build -S .
cmake --build build
cd build && ctest --output-on-failure
```

### Code Coverage

```bash
./scripts/coverage.sh
open coverage/html/index.html
```

### Code Formatting

```bash
# Format all files
pre-commit run --all-files

# Auto-format on commit
pre-commit install
```

### API Documentation

```bash
# Generate Doxygen documentation
./scripts/docs.sh

# View generated docs
open docs/html/index.html
```

## Project Structure

```
.
├── src/                 # Source files
├── include/             # Header files
├── tests/               # Unit tests (Google Test)
├── benchmarks/          # Performance benchmarks (Google Benchmark)
├── scripts/             # Build/test convenience scripts
├── .github/workflows/   # CI/CD configuration
├── CMakeLists.txt       # CMake configuration
├── Doxyfile             # Doxygen configuration for API docs
├── .clang-format        # Code formatting rules (Google style)
├── .pre-commit-config.yaml  # Pre-commit hooks
└── .editorconfig        # Editor configuration
```

## Using as a Template

1. Click "Use this template" on GitHub (or clone/fork)
2. Update the badge URLs in this README (lines 3-4) with your GitHub username/repo
3. Set up Codecov:
   - Create account at [codecov.io](https://codecov.io) and add your repository
   - Add `CODECOV_TOKEN` as a GitHub secret (Settings → Secrets and variables → Actions)
   - After first CI run with coverage, verify badges are working
4. Find and replace `hello_world` with your project name
5. Update `CMakeLists.txt` project name and version
6. Update this README with your project details
7. Start coding!

## CI/CD

GitHub Actions automatically:
- Builds on Ubuntu (GCC & Clang) and macOS
- Runs all tests
- Runs benchmarks
- **100% free for public repos!**

See `.github/workflows/ci.yml` for configuration.

## Compiler Support

### macOS with Homebrew Clang
The template auto-detects Homebrew LLVM and configures libc++ paths for C++23 support.

### macOS with GCC
Thread Sanitizer is automatically disabled on GCC/macOS (not well supported).

### Linux
Works with both GCC and Clang. TSAN fully supported.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions welcome! Please run `pre-commit install` and ensure tests pass.
