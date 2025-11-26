cmake_minimum_required(VERSION 3.25)
project(
  hello_world
  VERSION 0.1.0
  LANGUAGES CXX)

# Set C++23 standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Only disable Apple-specific flags if using GCC on macOS
if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(STATUS "Using GCC on macOS - disabling Apple-specific flags")
  set(CMAKE_OSX_ARCHITECTURES "")
  set(CMAKE_OSX_SYSROOT "")
  set(CMAKE_OSX_DEPLOYMENT_TARGET "")
  # GCC on macOS doesn't support TSAN well, disable it
  set(ENABLE_TSAN
      OFF
      CACHE BOOL "TSAN not supported with GCC on macOS" FORCE)
  message(
    WARNING
      "Thread Sanitizer (TSAN) is not supported with GCC on macOS ARM64 - disabling"
  )
endif()

# Configure Homebrew LLVM/Clang to use the correct libc++
if(APPLE AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  # Check if using Homebrew LLVM (path contains /opt/homebrew or /usr/local)
  if(CMAKE_CXX_COMPILER MATCHES "homebrew"
     OR CMAKE_CXX_COMPILER MATCHES "/opt/homebrew"
     OR CMAKE_CXX_COMPILER MATCHES "/usr/local")
    # Determine Homebrew prefix
    execute_process(
      COMMAND brew --prefix llvm
      OUTPUT_VARIABLE HOMEBREW_LLVM_PREFIX
      OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)

    if(HOMEBREW_LLVM_PREFIX)
      message(STATUS "Using Homebrew LLVM - configuring libc++ paths")
      add_link_options(-L${HOMEBREW_LLVM_PREFIX}/lib/c++)
      add_link_options(-Wl,-rpath,${HOMEBREW_LLVM_PREFIX}/lib/c++)
    endif()
  endif()
endif()

# Export compile commands for IDEs
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Add sanitizer options
option(ENABLE_TSAN "Enable Thread Sanitizer" ON)

if(ENABLE_TSAN)
  add_compile_options(-fsanitize=thread)
  add_link_options(-fsanitize=thread)
endif()

# Add coverage options
option(ENABLE_COVERAGE "Enable code coverage" OFF)

if(ENABLE_COVERAGE)
  add_compile_options(--coverage)
  add_link_options(--coverage)
endif()

# Include FetchContent for dependencies
include(FetchContent)

# Fetch Google Test
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.15.2)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt
    ON
    CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Fetch Google Benchmark
FetchContent_Declare(
  googlebenchmark
  GIT_REPOSITORY https://github.com/google/benchmark.git
  GIT_TAG v1.9.1)
set(BENCHMARK_ENABLE_TESTING
    OFF
    CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS
    OFF
    CACHE BOOL "" FORCE)
set(HAVE_STD_REGEX
    ON
    CACHE BOOL "" FORCE)
set(RUN_HAVE_STD_REGEX
    1
    CACHE STRING "" FORCE)
FetchContent_MakeAvailable(googlebenchmark)

# Main library
add_library(hello_world STATIC src/hello_world.cpp)
target_include_directories(
  hello_world PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                     $<INSTALL_INTERFACE:include>)

# Main executable
add_executable(hello_world_demo src/main.cpp)
target_link_libraries(hello_world_demo PRIVATE hello_world)

# Enable testing
enable_testing()

# Add subdirectories
add_subdirectory(tests)
add_subdirectory(benchmarks)
