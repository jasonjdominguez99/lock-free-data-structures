#!/bin/bash
set -e

# Generate Doxygen documentation
echo "Generating documentation with Doxygen..."

# Check if doxygen is installed
if ! command -v doxygen &> /dev/null; then
    echo "Error: doxygen is not installed"
    echo "Install with: brew install doxygen  (macOS)"
    echo "           or: apt install doxygen  (Linux)"
    exit 1
fi

# Generate docs
doxygen Doxyfile

echo "Documentation generated successfully!"
echo "Open docs/html/index.html to view"
