#!/usr/bin/env bash
# Build script for the project
# Usage:
#   ./scripts/build.sh [debug|debug-tsan|release] [compiler]
#   ./scripts/build.sh [debug|debug-tsan|release] --select
#   ./scripts/build.sh --list-compilers
#   ./scripts/build.sh --compiler-reset

set -e

BUILD_DIR="build"
CONFIG_FILE=".build_config"

# Parallel arrays for compiler configurations (bash 3.2 compatible)
COMPILER_NAMES=()
COMPILER_CC=()
COMPILER_CXX=()
COMPILER_DESC=()

# Add a compiler to the arrays
add_compiler() {
    local name=$1
    local cc=$2
    local cxx=$3
    local desc=$4

    COMPILER_NAMES+=("$name")
    COMPILER_CC+=("$cc")
    COMPILER_CXX+=("$cxx")
    COMPILER_DESC+=("$desc")
}

# Get full version string from compiler
get_compiler_version() {
    local compiler=$1
    # Get version, trim whitespace, take first line
    $compiler --version 2>/dev/null | head -1 | sed 's/^[^0-9]*//' | awk '{print $1}' || echo ""
}

# Detect available compilers
detect_compilers() {
    # Detect GCC versions (15, 14, 13, 12, 11)
    for version in 15 14 13 12 11; do
        if command -v gcc-$version &>/dev/null; then
            full_version=$(get_compiler_version gcc-$version)
            if [ -n "$full_version" ]; then
                add_compiler "gcc-$version" "gcc-$version" "g++-$version" "GCC $full_version"
            else
                add_compiler "gcc-$version" "gcc-$version" "g++-$version" "GCC $version"
            fi
        fi
    done

    # Detect Clang versions (19, 18, 17, 16, 15)
    for version in 19 18 17 16 15; do
        if command -v clang-$version &>/dev/null; then
            full_version=$(get_compiler_version clang-$version)
            if [ -n "$full_version" ]; then
                add_compiler "clang-$version" "clang-$version" "clang++-$version" "Clang $full_version"
            else
                add_compiler "clang-$version" "clang-$version" "clang++-$version" "Clang $version"
            fi
        fi
    done

    # Detect Homebrew LLVM
    if [ -d "/opt/homebrew/opt/llvm/bin" ]; then
        full_version=$(get_compiler_version /opt/homebrew/opt/llvm/bin/clang)
        if [ -n "$full_version" ]; then
            add_compiler "llvm" "/opt/homebrew/opt/llvm/bin/clang" "/opt/homebrew/opt/llvm/bin/clang++" "Homebrew LLVM $full_version"
        else
            add_compiler "llvm" "/opt/homebrew/opt/llvm/bin/clang" "/opt/homebrew/opt/llvm/bin/clang++" "Homebrew LLVM/Clang"
        fi
    fi

    # Detect system AppleClang (macOS) or system Clang (Linux)
    if command -v clang &>/dev/null && ! command -v clang-19 &>/dev/null; then
        full_version=$(get_compiler_version clang)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if [ -n "$full_version" ]; then
                add_compiler "appleclang" "clang" "clang++" "AppleClang $full_version"
            else
                add_compiler "appleclang" "clang" "clang++" "System AppleClang"
            fi
        else
            if [ -n "$full_version" ]; then
                add_compiler "clang" "clang" "clang++" "Clang $full_version"
            else
                add_compiler "clang" "clang" "clang++" "System Clang"
            fi
        fi
    fi

    # Detect system GCC if no versioned GCC found
    if command -v gcc &>/dev/null && [ ${#COMPILER_NAMES[@]} -eq 0 ]; then
        full_version=$(get_compiler_version gcc)
        if [ -n "$full_version" ]; then
            add_compiler "gcc" "gcc" "g++" "GCC $full_version"
        else
            add_compiler "gcc" "gcc" "g++" "System GCC"
        fi
    fi
}

# Find compiler index by name
find_compiler_index() {
    local name=$1
    local i=0
    for compiler_name in "${COMPILER_NAMES[@]}"; do
        if [ "$compiler_name" = "$name" ]; then
            echo "$i"
            return 0
        fi
        ((i++))
    done
    return 1
}

# Get compiler paths from name
get_compiler_paths() {
    local name=$1
    local idx

    idx=$(find_compiler_index "$name")
    if [ $? -ne 0 ]; then
        echo "Error: Unknown compiler '$name'" >&2
        return 1
    fi

    echo "${COMPILER_CC[$idx]}:${COMPILER_CXX[$idx]}"
}

# Find latest compiler matching a prefix (e.g., "gcc" finds latest gcc-14, gcc-13, etc.)
find_latest_compiler() {
    local prefix=$1
    local latest=""
    local latest_version=-1

    for compiler_name in "${COMPILER_NAMES[@]}"; do
        # Check if compiler name starts with prefix-
        if [[ "$compiler_name" == "$prefix-"* ]]; then
            # Extract version number
            local version="${compiler_name#$prefix-}"
            if [[ "$version" =~ ^[0-9]+$ ]] && [ "$version" -gt "$latest_version" ]; then
                latest_version=$version
                latest="$compiler_name"
            fi
        elif [ "$compiler_name" = "$prefix" ]; then
            # Exact match (e.g., system gcc/clang)
            latest="$compiler_name"
        fi
    done

    if [ -n "$latest" ]; then
        echo "$latest"
        return 0
    fi
    return 1
}

# Save compiler preference
save_compiler() {
    echo "$1" > "$CONFIG_FILE"
}

# Load compiler preference
load_compiler() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    fi
}

# Show interactive compiler menu
select_compiler_interactive() {
    echo "Select compiler:"
    local i=1
    local idx=0

    for compiler_name in "${COMPILER_NAMES[@]}"; do
        echo "  $i) $compiler_name - ${COMPILER_DESC[$idx]}"
        ((i++))
        ((idx++))
    done

    echo -n "Choice [1-${#COMPILER_NAMES[@]}]: "
    read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#COMPILER_NAMES[@]}" ]; then
        echo "Error: Invalid choice" >&2
        exit 1
    fi

    echo "${COMPILER_NAMES[$((choice-1))]}"
}

# Detect available compilers first (needed for all operations)
detect_compilers

if [ ${#COMPILER_NAMES[@]} -eq 0 ]; then
    echo "" >&2
    echo "Error: No suitable compilers found on your system" >&2
    echo "" >&2
    echo "Please install one of the following:" >&2
    echo "  - GCC (gcc-14, gcc-13, etc.)" >&2
    echo "  - Clang (clang-18, clang-17, etc.)" >&2
    echo "  - Xcode Command Line Tools (macOS)" >&2
    echo "  - Homebrew LLVM (brew install llvm)" >&2
    echo "" >&2
    exit 1
fi

# Handle --list-compilers flag
if [ "$1" = "--list-compilers" ]; then
    echo "Available compilers:"
    idx=0
    for compiler_name in "${COMPILER_NAMES[@]}"; do
        echo "  $compiler_name - ${COMPILER_DESC[$idx]}"
        ((idx++))
    done
    echo ""
    echo "Generic aliases:"
    if find_latest_compiler "gcc" &>/dev/null; then
        latest=$(find_latest_compiler "gcc")
        echo "  gcc -> $latest"
    fi
    if find_latest_compiler "clang" &>/dev/null; then
        latest=$(find_latest_compiler "clang")
        echo "  clang -> $latest"
    fi
    exit 0
fi

# Handle --compiler-reset flag
if [ "$1" = "--compiler-reset" ]; then
    if [ -f "$CONFIG_FILE" ]; then
        rm "$CONFIG_FILE"
        echo "Compiler preference cleared."
    else
        echo "No saved compiler preference."
    fi
    exit 0
fi

# Parse arguments
BUILD_TYPE="${1:-debug}"
COMPILER_ARG="$2"

# Validate build type
case "$BUILD_TYPE" in
  debug|debug-tsan|release)
    ;;
  *)
    echo "Usage: $0 [debug|debug-tsan|release] [compiler|--select]"
    echo "   or: $0 --list-compilers"
    echo "   or: $0 --compiler-reset"
    exit 1
    ;;
esac

# Determine which compiler to use
SELECTED_COMPILER=""

if [ "$COMPILER_ARG" = "--select" ]; then
    # Force interactive selection
    SELECTED_COMPILER=$(select_compiler_interactive)
    save_compiler "$SELECTED_COMPILER"
elif [ -n "$COMPILER_ARG" ]; then
    # Explicit compiler specified
    # First try exact match
    if find_compiler_index "$COMPILER_ARG" >/dev/null 2>&1; then
        SELECTED_COMPILER="$COMPILER_ARG"
    else
        # Try to find latest version matching prefix (e.g., "gcc" -> "gcc-14")
        SELECTED_COMPILER=$(find_latest_compiler "$COMPILER_ARG" 2>/dev/null || true)
        if [ -z "$SELECTED_COMPILER" ]; then
            echo "" >&2
            echo "Error: Compiler '$COMPILER_ARG' not found" >&2
            echo "" >&2
            echo "Available compilers on your system:" >&2
            idx=0
            for name in "${COMPILER_NAMES[@]}"; do
                echo "  - $name (${COMPILER_DESC[$idx]})" >&2
                ((idx++))
            done
            echo "" >&2
            # Show suggestion if it looks like a typo
            if [[ "$COMPILER_ARG" == "clang" ]] && find_compiler_index "appleclang" >/dev/null 2>&1; then
                echo "Did you mean 'appleclang' (macOS system clang)?" >&2
            elif [[ "$COMPILER_ARG" == "gcc" ]] && find_latest_compiler "gcc-" >/dev/null 2>&1; then
                suggested=$(find_latest_compiler "gcc-" 2>/dev/null || echo "gcc-XX")
                echo "Tip: Use 'gcc' to auto-select latest, or try '$suggested' for a specific version" >&2
            fi
            echo "" >&2
            exit 1
        fi
        echo "Note: '$COMPILER_ARG' resolved to '$SELECTED_COMPILER'"
    fi
    save_compiler "$SELECTED_COMPILER"
else
    # No compiler specified, try to load saved preference
    SAVED_COMPILER=$(load_compiler)
    if [ -n "$SAVED_COMPILER" ] && find_compiler_index "$SAVED_COMPILER" >/dev/null 2>&1; then
        SELECTED_COMPILER="$SAVED_COMPILER"
    else
        # No saved preference, show menu
        SELECTED_COMPILER=$(select_compiler_interactive)
        save_compiler "$SELECTED_COMPILER"
    fi
fi

# Get compiler paths
COMPILER_PATHS=$(get_compiler_paths "$SELECTED_COMPILER")
IFS=':' read -r C_COMPILER CXX_COMPILER <<< "$COMPILER_PATHS"

echo "Using compiler: $SELECTED_COMPILER ($C_COMPILER / $CXX_COMPILER)"

# Check if compiler changed since last build - if so, clean to avoid CMake cache issues
COMPILER_MARKER="$BUILD_DIR/.last_compiler"
if [ -f "$COMPILER_MARKER" ]; then
    LAST_COMPILER=$(cat "$COMPILER_MARKER")
    if [ "$LAST_COMPILER" != "$SELECTED_COMPILER" ]; then
        echo "Compiler changed from $LAST_COMPILER to $SELECTED_COMPILER - cleaning build directory..."
        rm -rf "$BUILD_DIR"
    fi
fi

# Save current compiler for next build
mkdir -p "$BUILD_DIR"
echo "$SELECTED_COMPILER" > "$COMPILER_MARKER"

# Configure CMake with selected compiler
case "$BUILD_TYPE" in
  debug)
    echo "Building in Debug mode (ASAN + UBSAN, warnings as errors)..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_COMPILER="$C_COMPILER" \
      -DCMAKE_CXX_COMPILER="$CXX_COMPILER" \
      -DENABLE_ASAN=ON \
      -DENABLE_UBSAN=ON \
      -DENABLE_TSAN=OFF
    ;;
  debug-tsan)
    echo "Building in Debug mode with Thread Sanitizer (warnings as errors)..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_COMPILER="$C_COMPILER" \
      -DCMAKE_CXX_COMPILER="$CXX_COMPILER" \
      -DENABLE_ASAN=OFF \
      -DENABLE_UBSAN=OFF \
      -DENABLE_TSAN=ON
    ;;
  release)
    echo "Building in Release mode (no sanitizers, warnings enabled)..."
    cmake -B "$BUILD_DIR" -S . \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER="$C_COMPILER" \
      -DCMAKE_CXX_COMPILER="$CXX_COMPILER" \
      -DENABLE_ASAN=OFF \
      -DENABLE_UBSAN=OFF \
      -DENABLE_TSAN=OFF
    ;;
esac

# Build with all available cores
cmake --build "$BUILD_DIR" -j $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "Build complete! Binaries in $BUILD_DIR/"
