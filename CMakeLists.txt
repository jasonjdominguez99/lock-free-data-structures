cmake_minimum_required(VERSION 3.25)
project(
  lock_free_data_structures
  VERSION 0.1.0
  LANGUAGES CXX)

# Set C++23 standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Define warning flags for project targets only (not third-party dependencies)
set(PROJECT_WARNING_FLAGS -Wall -Wextra -Wpedantic -Wshadow -Wuninitialized
                          -Wconversion)

# Add compiler-specific warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  list(APPEND PROJECT_WARNING_FLAGS -Wmost -Wthread-safety)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  list(APPEND PROJECT_WARNING_FLAGS -Wduplicated-cond -Wlogical-op)
endif()

# Add -Werror for Debug builds only
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  list(APPEND PROJECT_WARNING_FLAGS -Werror)
endif()

# Only disable Apple-specific flags if using GCC on macOS
if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(STATUS "Using GCC on macOS - disabling Apple-specific flags")
  set(CMAKE_OSX_ARCHITECTURES "")
  set(CMAKE_OSX_SYSROOT "")
  set(CMAKE_OSX_DEPLOYMENT_TARGET "")
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
option(ENABLE_ASAN "Enable Address Sanitizer" OFF)
option(ENABLE_UBSAN "Enable Undefined Behavior Sanitizer" OFF)
option(ENABLE_TSAN "Enable Thread Sanitizer" OFF)

# GCC on macOS doesn't include sanitizer runtime libraries - disable them
if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(ENABLE_ASAN)
    message(
      WARNING
        "Address Sanitizer (ASAN) is not supported with GCC on macOS - disabling"
    )
    set(ENABLE_ASAN
        OFF
        CACHE BOOL "ASAN not supported with GCC on macOS" FORCE)
  endif()
  if(ENABLE_UBSAN)
    message(
      WARNING
        "Undefined Behavior Sanitizer (UBSAN) is not supported with GCC on macOS - disabling"
    )
    set(ENABLE_UBSAN
        OFF
        CACHE BOOL "UBSAN not supported with GCC on macOS" FORCE)
  endif()
  if(ENABLE_TSAN)
    message(
      WARNING
        "Thread Sanitizer (TSAN) is not supported with GCC on macOS - disabling"
    )
    set(ENABLE_TSAN
        OFF
        CACHE BOOL "TSAN not supported with GCC on macOS" FORCE)
  endif()
endif()

if(ENABLE_ASAN)
  add_compile_options(-fsanitize=address)
  add_link_options(-fsanitize=address)
endif()

if(ENABLE_UBSAN)
  add_compile_options(-fsanitize=undefined)
  add_link_options(-fsanitize=undefined)
endif()

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

# Benchmark support (opt-in, use ./scripts/benchmark.sh to enable)
option(BUILD_BENCHMARKS "Build benchmark executables" OFF)

if(BUILD_BENCHMARKS)
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
endif()

# Main library
add_library(data_structures STATIC src/utils.cpp)
target_include_directories(
  data_structures PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                         $<INSTALL_INTERFACE:include>)
target_compile_options(data_structures PRIVATE ${PROJECT_WARNING_FLAGS})

# Main executable
add_executable(lock_free_data_structures_demo src/main.cpp)
target_link_libraries(lock_free_data_structures_demo PRIVATE data_structures)
target_compile_options(lock_free_data_structures_demo
                       PRIVATE ${PROJECT_WARNING_FLAGS})

# Enable testing
enable_testing()

# Add subdirectories
add_subdirectory(tests)

if(BUILD_BENCHMARKS)
  add_subdirectory(benchmarks)
  message(STATUS "Benchmarks enabled")
else()
  message(
    STATUS "Benchmarks disabled (run ./scripts/benchmark.sh to build and run)")
endif()
