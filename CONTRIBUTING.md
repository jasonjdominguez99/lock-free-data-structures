# Contributing

Thank you for your interest in contributing! This guide will help you get started.

## Development Setup

### Prerequisites

- CMake 3.25+
- C++23 compatible compiler (GCC 14+ or Clang 16+)
- Python 3.7+ (for pre-commit hooks)
- (Optional) lcov for coverage reports

### Initial Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd modern-cpp-project-template

# Install pre-commit hooks
pip install pre-commit
pre-commit install
```

## Building the Project

### Using Convenience Scripts

```bash
# Build in release mode (default)
./scripts/build.sh

# Build in debug mode
./scripts/build.sh debug

# Build with Thread Sanitizer
./scripts/build.sh tsan
```

### Manual CMake

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## Running Tests

```bash
# Run all tests
./scripts/test.sh

# Or manually
cd build && ctest --output-on-failure
```

## Running Benchmarks

```bash
# Quick benchmarks
./scripts/benchmark.sh

# Full benchmarks
./build/benchmarks/hello_world_benchmark
```

## Code Coverage

```bash
# Generate coverage report
./scripts/coverage.sh

# View results
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## Code Style

### Formatting (clang-format)

This project uses **Google C++ Style** with clang-format.

```bash
# Format all files
pre-commit run clang-format --all-files

# Or manually
clang-format -i src/*.cpp include/*.h
```

Pre-commit hooks will automatically format code before commits.

## Documentation Style

Use Doxygen comments for all public APIs:

```cpp
/**
 * @brief Brief description of the function
 *
 * Detailed description if needed.
 *
 * @param name Parameter description
 * @return Description of return value
 */
std::string my_function(const std::string& name);
```

See `include/hello_world.h` for examples.

### Generating Documentation

```bash
# Install Doxygen (if not already installed)
brew install doxygen  # macOS
# or
sudo apt install doxygen  # Linux

# Generate documentation
./scripts/docs.sh

# Or manually
doxygen Doxyfile

# View generated docs
open docs/html/index.html  # macOS
xdg-open docs/html/index.html  # Linux
```

The generated documentation will be in the `docs/` directory (git-ignored).

## Pull Request Process

1. **Create a branch** from `master` for your changes
2. **Make your changes** following the code style
3. **Add tests** for new functionality
4. **Run tests and coverage** to ensure nothing breaks
5. **Update documentation** if adding features
6. **Run pre-commit hooks**: `pre-commit run --all-files`
7. **Submit a PR** with a clear description of changes

### PR Checklist

- [ ] Code follows style guide (clang-format applied)
- [ ] All tests pass (`./scripts/test.sh`)
- [ ] New tests added for new features
- [ ] Documentation updated (if needed)
- [ ] Pre-commit hooks pass
- [ ] No compiler warnings

## Commit Messages

Write clear, concise commit messages:

```
Brief summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain the problem this commit solves and why this approach
was chosen.
```

## Project Structure

```
.
├── src/                 # Source files (.cpp)
├── include/             # Public headers (.h)
├── tests/               # Unit tests (Google Test)
├── benchmarks/          # Performance benchmarks (Google Benchmark)
├── scripts/             # Build/test convenience scripts
├── .github/workflows/   # CI/CD configuration
├── CMakeLists.txt       # Main CMake configuration
├── Doxyfile             # Doxygen configuration for API docs
├── .clang-format        # Code formatting rules
└── .pre-commit-config.yaml  # Pre-commit hooks
```

## Getting Help

- Open an issue for bugs or feature requests
- Check existing issues before creating new ones
- Be respectful and constructive in discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
